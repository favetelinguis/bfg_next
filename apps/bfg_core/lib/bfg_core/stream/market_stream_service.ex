defmodule BfgCore.Stream.MarketStreamService do
  @market_stream_provider Application.get_env(:bfg_core, :market_stream_provider)

  def subscribe_price(identifier, market_place) do
    @market_stream_provider.subscribe_price(identifier, market_place)
  end

  def unsubscribe_price(identifier, market_place) do
    @market_stream_provider.unsubscribe_price(identifier, market_place)
  end

  def subscribe_news(source) do
    @market_stream_provider.subscribe_news(source)
  end

  def unsubscribe_news(source) do
    @market_stream_provider.unsubscribe_news(source)
  end
end
