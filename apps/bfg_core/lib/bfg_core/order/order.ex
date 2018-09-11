defmodule BfgCore.Order do
  @order %{
    instrument: nil,
    units: nil,
    side: nil,
    order_type: nil,
    take_profit: nil,
    stop_loss: nil,
    order_id: nil,
    price: nil
  }

  def new_limit_order(instrument, units, side, order_type, price) do
    %{
      @order
      | instrument: instrument,
        units: units,
        side: side,
        order_type: order_type,
        price: price
    }
  end

  def new_market_order(instrument, units, side, order_type) do
    %{@order | instrument: instrument, units: units, side: side, order_type: order_type}
  end

  def new_limit_order_with_targets(
        instrument,
        units,
        side,
        order_type,
        take_profit,
        stop_loss,
        price
      ) do
    %{
      @order
      | instrument: instrument,
        units: units,
        side: side,
        order_type: order_type,
        take_profit: take_profit,
        stop_loss: stop_loss,
        price: price
    }
  end
end
