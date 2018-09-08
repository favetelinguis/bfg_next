defmodule BfgCore.Instrument.TradeableInstrument do
  def new(values) do
    %{
      # Unique identifier of the instrument. Can in some cases be 0 if the instrument is not tradable
      instrument_id: Keyword.get(values, :instrument_id),
      tick_size: Keyword.get(values, :tick_size),
      symbol: Keyword.get(values, :symbol)
    }
  end

  # TODO nice to have get_tick(prize)

  """
  Tick size
  [
    {
      "tick_size_id": 14560,
      "ticks": [
        {
          "decimals": 4,
          "from_price": 0,
          "to_price": 0.9999,
          "tick": 0.0001
        },
        {
          "decimals": 2,
          "from_price": 1,
          "to_price": 99999.98,
          "tick": 0.01
        },
        {
          "decimals": 1,
          "from_price": 100000,
          "to_price": 999999.89,
          "tick": 0.1
        }
      ]
    }
  ]
  """
end
