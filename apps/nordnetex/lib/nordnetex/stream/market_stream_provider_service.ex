defmodule Nordnetex.Stream.MarketStreamProviderService do
  use Connection
  require Logger
  @me __MODULE__

  @behaviour BfgCore.Stream.MarketStreamProvider

  @initial_state %{
    socket: nil,
    session_key: nil,
    connection_details: nil,
    active_subscriptions: %{},
    keep_alive_ref: nil
  }
  alias Nordnetex.Stream.SubscriptionStore
  alias Nordnetex.Stream.MarketStreamMessageHub

  ############################################################
  # Client
  ############################################################
  def start_link(args), do: Connection.start_link(@me, args, name: @me)

  @impl true
  def subscribe_price(identifier, market_place) do
    data = %{
      "cmd" => "subscribe",
      "args" => %{"t" => "price", "i" => identifier, "m" => market_place}
    }

    key = {identifier, market_place}
    Connection.cast(@me, {:send_data, data, :subscribe, key})
  end

  @impl true
  def unsubscribe_price(identifier, market_place) do
    data = %{
      "cmd" => "unsubscribe",
      "args" => %{"t" => "price", "i" => identifier, "m" => market_place}
    }

    key = {identifier, market_place}
    Connection.cast(@me, {:send_data, data, :unsubscribe, key})
  end

  @impl true
  def subscribe_news(source) do
    data = %{"cmd" => "subscribe", "args" => %{"t" => "news", "s" => source}}
    key = {source}
    Connection.cast(@me, {:send_data, data, :subscribe, key})
  end

  @impl true
  def unsubscribe_news(source) do
    data = %{"cmd" => "unsubscribe", "args" => %{"t" => "news", "s" => source}}
    key = {source}
    Connection.cast(@me, {:send_data, data, :unsubscribe, key})
  end

  ############################################################
  # Callback
  ############################################################
  @impl true
  def init({session_key, connection_details}) do
    # Needed to save state before exit
    Process.flag(:trap_exit, true)

    state =
      SubscriptionStore.get_market_subscription_state() ||
        %{@initial_state | session_key: session_key, connection_details: connection_details}

    {:connect, :init, state}
  end

  @impl true
  def connect(
        _,
        %{connection_details: {host, port}, session_key: session_key, active_subscriptions: subs} =
          state
      ) do
    opts = [:binary, active: :once, packet: :line] #packet line lets erlang buffer until /n and full message

    case :ssl.connect(host, port, opts) do
      {:ok, socket} ->
        data = %{"cmd" => "login", "args" => %{"session_key" => session_key}}
        :ok = :ssl.send(socket, Poison.encode!(data) <> "\n")
        handle_resubscriptions(socket, subs)
        Logger.info("Market stream subscription ok")
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
    Logger.warn("Market stream terminate called, closing socket")
    :ssl.close(state.socket)
    state = %{state | socket: nil, keep_alive_ref: nil}
    SubscriptionStore.set_market_subscription_state(state)
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
    MarketStreamMessageHub.handle_message(msg)
    {:noreply, %{state | keep_alive_ref: reschedule_keep_alive(state.keep_alive_ref)}}
  end

  @impl true
  def handle_info(:keep_alive, state) do
    Logger.warn("No keep alive on market stream for 6s resubscribing")
    {:disconnect, :reconnect, state}
  end

  @impl true
  def handle_info({:ssl_closed, _}, state) do
    Logger.warn("SSL connection closed, resubscribing")
    {:disconnect, :reconnect, state}
  end

  @doc """
  If no socket connection is done do nothing
  """
  @impl true
  def handle_cast(_, %{socket: nil}) do
    Logger.error("Not connected while trying to send message")
  end

  @impl true
  def handle_cast({:send_data, data, :subscribe, key}, %{socket: socket} = state) do
    Logger.debug("Sending message: #{inspect(data)}")
    :ok = :ssl.send(socket, Poison.encode!(data) <> "\n")
    {:noreply, add_subscription(state, key, data)}
  end

  @impl true
  def handle_cast({:send_data, data, :unsubscribe, key}, %{socket: socket} = state) do
    Logger.debug("Sending message: #{inspect(data)}")
    :ok = :ssl.send(socket, Poison.encode!(data) <> "\n")
    {:noreply, remove_subscription(state, key)}
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

  defp add_subscription(state, key, data) do
    %{state | active_subscriptions: Map.put_new(state.active_subscriptions, key, data)}
  end

  defp remove_subscription(state, key) do
    %{state | active_subscriptions: Map.drop(state.active_subscriptions, [key])}
  end

  defp handle_resubscriptions(_socket, subscriptions) when subscriptions == %{} do
    Logger.debug("No subscriptions to resubscribe to")
    nil
  end

  defp handle_resubscriptions(socket, subscriptions) do
    Enum.each(subscriptions, fn {_key, data} ->
      Logger.info("Resubscribing #{inspect(data)}")
      :ok = :ssl.send(socket, Poison.encode!(data) <> "\n")
    end)
  end
end
