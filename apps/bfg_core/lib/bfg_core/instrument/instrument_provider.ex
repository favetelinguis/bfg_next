defmodule BfgCore.Instrument.InstrumentProvider do
  @moduledoc """
  A provider of tradeable instrument data information. At the very minimum the
  provider must provide the instrument name and pip value for each instrument.
  Since the instrument data almost never changes during trading hours, it is
  highly recommended that the data returned from this provider is cached in an
  immutable collection.
  """

  @doc """
  return a collection of all tradable instruments on the platform
  """
  @callback get_instruments :: [map]
end
