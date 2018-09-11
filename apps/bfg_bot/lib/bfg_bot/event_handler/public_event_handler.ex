defmodule BfgBot.EventHandler.PublicEventHandler do
  require Logger
  @behaviour BfgCore.Stream.PublicEventHandler

  alias BfgBot.Strategy.{StrategyCache, StrategyServer}

  @impl
  def handle_price(event) do
    BfgCore.Price.market_and_identifier(event)
    |> StrategyCache.server_process()
    |> StrategyServer.handle_price(event)
  end

  @impl
  def handle_news(event) do
    Logger.info("Got news: #{inspect(event)}")
  end
end
