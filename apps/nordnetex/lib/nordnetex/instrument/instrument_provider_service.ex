defmodule Nordnetex.Instrument.InstrumentProviderService do
  @behaviour BfgCore.Instrument.InstrumentProvider

  require Logger
  import Nordnetex.Session.SessionManager, only: [get: 1]
  alias BfgCore.TradeableInstrument

  @impl true
  def get_instruments do
    {:ok, response} = get("/instruments?query=*") #TODO this sucks i just get 100 first
    response
    |> Enum.map(&map_to_instrument/1)
  end

  defp map_to_instrument(instrument) do
    TradeableInstrument.new(
      tradeable_id: instrument["instrument_id"],
      symbol: instrument["symbol"]
      #TODO need to also fill in tick size
    )
  end
end