defmodule BfgCore.Price do
  def new(
        tradable_instrument_id,
        market_id,
        time_last_trade,
        event_time,
        bid_price,
        bid_volume,
        ask_price,
        ask_volume,
        open,
        high,
        low,
        close,
        volume,
        turnover,
        last_price,
        last_volume
      ) do
    %{
      tradable_instrument_id: tradable_instrument_id,
      market_id: market_id,
      time_last_trade: time_last_trade,
      event_time: event_time,
      bid_price: bid_price,
      bid_volume: bid_volume,
      ask_price: ask_price,
      ask_volume: ask_volume,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
      turnover: turnover,
      last_price: last_price,
      last_volume: last_volume
    }
  end

  def market_and_identifier(price) do
    {price.market_id, price.tradable_instrument_id}
  end
end
