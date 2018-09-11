defmodule BfgBot.EventHandler.PrivateEventHandler do
  require Logger
  @behaviour BfgCore.Stream.PrivateEventHandler

  @impl true
  def handle_order(event) do
    Logger.info("Got order: #{inspect(event)}")
  end

  @impl true
  def handle_trade(event) do
    Logger.info("Got trade: #{inspect(event)}")
  end
end
