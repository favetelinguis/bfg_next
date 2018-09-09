defmodule Nordnetex.Stream.OrderStream do
    use Connection
    require Logger
    @me __MODULE__


  @initial_state %{
    socket: nil,
    session_key: nil,
    connection_details: nil,
    keep_alive_ref: nil
  }
  alias Nordnetex.Stream.SubscriptionStore
  alias Nordnetex.Stream.OrderStreamMessageHub

  ############################################################
  # Client
  ############################################################
  def start_link(args), do: Connection.start_link(@me, args, name: @me)

  ############################################################
  # Callback
  ############################################################
  @impl true
  def init({session_key, connection_details}) do
    # Needed to save state before exit
    Process.flag(:trap_exit, true)

    state =
      SubscriptionStore.get_order_subscription_state() ||
        %{@initial_state | session_key: session_key, connection_details: connection_details}

    {:connect, :init, state}
  end

  @impl true
  def connect(
        _,
        %{connection_details: {host, port}, session_key: session_key} =
          state
      ) do
    opts = [:binary, active: :once, packet: :line] #packet line lets erlang buffer until /n and full message

    case :ssl.connect(host, port, opts) do
      {:ok, socket} ->
        data = %{"cmd" => "login", "args" => %{"session_key" => session_key}}
        :ok = :ssl.send(socket, Poison.encode!(data) <> "\n")
        Logger.info("Order stream login ok")
        {:ok, %{state | socket: socket}}

      {:error, _reason} ->
        {:backoff, 5000, state}
    end
  end

  @doc """
  Clean up and then try to reconnect after 5 seconds again
  """
  @impl true
  def disconnect(_info, %{socket: socket, keep_alive_ref: timer_ref} = state) do
    if timer_ref do
      Process.cancel_timer(timer_ref)
    end

    # Try to close dont care if it fails
    :ssl.close(socket)
    {:backoff, 5000, state}
  end

  @doc """
  Saves state when restarting connection,
  clean state from things not relevant in a restart
  """
  @impl true
  def terminate(_reason, state) do
    Logger.warn("Order stream terminate called, closing socket")
    :ssl.close(state.socket)
    state = %{state | socket: nil, keep_alive_ref: nil}
    SubscriptionStore.set_order_subscription_state(state)
  end

  def child_spec(args) do
    %{
      id: @me,
      start: {@me, :start_link, [args]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  @doc """
  Each time a new message comes in we reschedule the keep alive warning, if a message is not recived before the
  keep alive period then a error is logged since the connection is dead
  """
  @impl true
  def handle_info({:ssl, socket, msg}, %{socket: socket} = state) do
    # Reactivate socket to recive next message
    :ssl.setopts(socket, active: :once)
    OrderStreamMessageHub.handle_message(msg)
    {:noreply, %{state | keep_alive_ref: reschedule_keep_alive(state.keep_alive_ref)}}
  end

  @impl true
  def handle_info(:keep_alive, state) do
    Logger.warn("No keep alive on order stream for 6s resubscribing")
    {:disconnect, :reconnect, state}
  end

  @impl true
  def handle_info({:ssl_closed, _}, state) do
    Logger.warn("SSL connection closed, resubscribing")
    {:disconnect, :reconnect, state}
  end

  ############################################################
  # Impl
  ############################################################
  defp reschedule_keep_alive(timer_ref) do
    if timer_ref do
      Process.cancel_timer(timer_ref)
    end

    # Add 1000ms extra time for message
    Process.send_after(self(), :keep_alive, 5000 + 1000)
  end
end