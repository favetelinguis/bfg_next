defmodule BfgBot.EventHandler.PublicEventHandler do 
    require Logger
    @behaviour BfgCore.Stream.PublicEventHandler

    @impl
    def handle_price(event) do
        Logger.info("Got price: #{inspect event}")
    end

    @impl
    def handle_news(event) do
        Logger.info("Got news: #{inspect event}")
    end
end