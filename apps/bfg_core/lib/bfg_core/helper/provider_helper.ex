defmodule BfgCore.Helper.ProviderHelper do
  @moduledoc false

  @doc """
  instrument in ISO currency standard, such as GBPUSD
  returns currency pair denoted in the platform specific format
  """
  @callback from_iso_format(instrument :: String.t()) :: String.t()

  @doc """
  instrument in platform specific format such as GBP_USD
  returns currency pair denoted in ISO format
  """
  @callback to_iso_format(instrument :: String.t()) :: String.t()

  @doc """
  instrument in platform specific format such as GBP_USD
  returns currency pair denoted in ISO format
  """
  @callback to_iso_format(instrument :: String.t()) :: String.t()

  @doc """
  instrument in a 7 character format, separated by an arbitrary separator
  character like -,/,_
  returns currency pair denoted in the platform specific format
  """
  @callback from_pair_separator_format(instrument :: String.t()) :: String.t()

  @doc """
  instrument denoted as a hashtag, for e.g. #GBPUSD
  returns currency pair denoted in the platform specific format
  """
  @callback from_hash_tag_currency(instrument :: String.t()) :: String.t()

  @doc """
  return symbol that denotes the action of Buying the currency pair on the platform
  """
  @callback get_long_notation :: String.t()

  @doc """
  return symbol that denotes the action of Selling the currency pair on the platform
  """
  @callback get_short_notation :: String.t()
end
