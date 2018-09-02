defmodule Nordnetex.Session.SessionManager do
  @moduledoc """
  Set up a rest session at Nordnet and makes sure the session is alive
  infinitly. If it expires the session is renewed.
  To prevent the session to expire the session is touched at a regular interval
  even if no request is made within the interval.
  """

  use Connection
  require Logger

  @me __MODULE__

  @username Application.get_env(:nordnetex, :nordnet_user)
  @password Application.get_env(:nordnetex, :nordnet_password)
  @public_key_filename Application.get_env(:nordnetex, :public_key_filename)
  @service_id Application.get_env(:nordnetex, :service_id)

  @initial_state %{
    alive: false,
    login_time: nil,
    last_touch: nil,
    session_key: nil,
    touch_session_interval: nil,
    last_touch_ref: nil,
    public_feed_hostname: nil,
    public_feed_port: nil,
    private_feed_hostname: nil,
    private_feed_port: nil,
  }

  alias Nordnetex.Rest.Api
  alias Nordnetex.Session.Crypto

  ############################################################
  # Client
  ############################################################
  def start_link(), do: Connection.start_link(@me, nil, name: @me)

  def get(path) when is_bitstring(path),
      do: Connection.call(@me, {:get, path})

  ############################################################
  # Callbacks
  ############################################################
  def init(_) do
    Logger.info("#{@me} started")
    {:connect, :init, @initial_state}
  end

  def connect(_, %{alive: false} = s) do
    blob = Crypto.encrypt_auth_parameter(@username, @password, @public_key_filename)
    body = %{auth: blob, service: @service_id}

    headers = ["content-type": "application/json"]
    "/login"
    |> Api.post(body, headers)
    |> handle_login_response(s)
  end

  def handle_info(:touch, %{session_key: session_key} = s) do
    Logger.info("Touching session")
    "/login"
    |> Api.put("", [], session_key: session_key)
    |> handle_touch_response(s)
  end

  @doc """
  Make sure no calls can be made on the connection if its closed
  """
  def handle_call(_, _, %{alive: false} = s) do
    {:reply, {:error, :closed}, s}
  end

  def handle_call({:get, path}, _from, %{session_key: session_key} = s) do
    path
    |> Api.get([], session_key: session_key)
    |> handle_response(s)
  end

  def child_spec(_arg) do
    %{
      id: @me,
      start: {@me, :start_link, []},
      type: :worker
    }
  end

  ############################################################
  # Impl
  ############################################################
  defp handle_login_response({:ok, %{status_code: 200, body: body}}, s) do
    # Sucessful login, setup keep alive interval and streams
    Logger.info("Response code body #{inspect body}")

    s = %{s |
        alive: true,
        login_time: DateTime.utc_now(),
        last_touch: DateTime.utc_now(),
        session_key: body["session_key"],
        touch_session_interval: body["expires_in"],
        last_touch_ref: schedule_session_touch(body["expires_in"], s.last_touch_ref),
        public_feed_hostname: body["public_feed"]["hostname"],
        public_feed_port: body["public_feed"]["port"],
        private_feed_hostname: body["private_feed"]["hostname"],
        private_feed_port: body["private_feed"]["port"],
    }
    {:ok, s}
  end

  defp handle_login_response({:ok, %{status_code: 400, body: body}}, s) do
    Logger.error("Login fail #{body["code"]}, #{body["message"]}")
    {:stop, :error, s}
  end

  defp handle_login_response({:ok, %{status_code: 401, body: body}}, s) do
    Logger.error("Login fail #{body["code"]}, #{body["message"]}")
    {:stop, :error, s}
  end

  defp handle_login_response({:ok, %{status_code: 429}}, s) do
    Logger.error("To many attempts i should wait 10 secs")
    {:stop, :error, s}
  end

  defp handle_login_response(response, s) do
    # TODO for all other error I should just try to reconnect
    Logger.warn("Unhandled response #{inspect response}")
    {:backoff, 4000, s}
  end

  defp handle_touch_response({:ok, %{status_code: 200, body: %{"logged_in" => true}}}, s) do
    s = %{s |
      last_touch: DateTime.utc_now(),
      last_touch_ref: schedule_session_touch(s.touch_session_interval, s.last_touch_ref),
    }
    {:noreply, s}
  end

  defp handle_touch_response({:ok, %{status_code: 400, body: body}}, s) do
    Logger.error("Session touch fail #{body["code"]}, #{body["message"]}")
    {:stop, :error, s}
  end

  defp handle_touch_response({:ok, %{status_code: 401, body: body}}, s) do
    Logger.warn("Session has expired renewing #{body["code"]}, #{body["message"]}")
    {:stop, :expired, s}
  end

  defp handle_touch_response({:ok, %{status_code: 429}}, s) do
    Logger.error("To many attempts i should wait 10 secs")
    {:stop, :error, s}
  end

  defp handle_touch_response(response, s) do
    # TODO for all other error I should just try to reconnect
    Logger.warn("Unhandled response #{inspect response}")
    {:stop, :error, s}
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}, s) do
    Logger.info("Response code body #{inspect body}")

    s = %{s |
      last_touch_ref: schedule_session_touch(s.touch_session_interval, s.last_touch_ref),
    }
    {:reply, {:ok, body}, s}
  end

  defp handle_response({:ok, %{status_code: 204}}, s) do
    Logger.error("No content in reply")
    {:reply, {:error, :nordnet_error}, s}
  end

  defp handle_response({:ok, %{status_code: 401, body: body}}, s) do
    # TODO this is not a good way since the caller wont get a reply, I should use the disconnection sulution in the connection docs
    # code = NEXT_INVALID_SESSION
    Logger.warn("Session has expired renewing #{body["code"]}, #{body["message"]}")
    {:stop, :expired, s}
  end

  defp handle_response({:ok, %{status_code: 403}}, s) do
    Logger.error("User is logged in but user or system does not have priviliges to use this endpoint")
    {:reply, {:error, :nordnet_error}, s}
  end

  defp handle_response({:ok, %{status_code: 429}}, s) do
    Logger.error("To many attempts i should wait 10 secs")
    {:reply, {:error, :nordnet_error}, s}
  end

  defp handle_response(response, s) do
    Logger.warn("Unhandled response #{inspect response}")
    {:reply, {:error, :nordnet_error}, s}
  end

  defp schedule_session_touch(timeout, last_ref) do
    if last_ref do Process.cancel_timer(last_ref) end
     # Nordnet send seconds intervall convert to milliseconds
     # Trigger session touch 10 seconds before timeout
    Process.send_after(self(), :touch, (timeout - 10) * 1000)
  end
end