defmodule BfgBot.Strategy.StrategyServer do
  use GenServer, restart: :transient
  require Logger

  alias BfgBot.Strategy.StrategyRules

  @init_state %{
    market_id: nil,
    rules: StrategyRules.new()
  }

  def start_link(market_and_identifer) do
    Logger.info("Starting strategy server for #{inspect market_and_identifer}")
    GenServer.start_link(__MODULE__, market_and_identifer, name: via_tuple(market_and_identifer))
  end

  def handle_price(pid, event), do: GenServer.cast(pid, {:price_event, event})

  @impl true
  def init(market_and_identifer) do
    {:ok, %{@init_state | market_id: market_and_identifer}}
  end

  def handle_cast({:price_event, event}, state) do
    Logger.info("Got price: #{inspect(event)}")
    {:noreply, state}
  end

  defp via_tuple(market_and_identifer) do
    {__MODULE__, market_and_identifer}
    |> BfgBot.Strategy.StrategyRegistry.via_tuple()
  end
end
