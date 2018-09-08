defmodule BfgCore.Stream.MarketStreamProvider do
  @doc """
  Subscribe to price ticks
  eg ERIC B i 101 m 11
  """
  @callback subscribe_price(identifier :: String.t(), market_place :: integer) :: none

  @doc """
  Subscribe to price ticks
  """
  @callback unsubscribe_price(identifier :: String.t(), market_place :: integer) :: none

  @doc """
  Subscribe to news
  """
  @callback subscribe_news(source :: integer) :: none

  @doc """
  Subscribe to news
  """
  @callback unsubscribe_news(source :: integer) :: none
end
