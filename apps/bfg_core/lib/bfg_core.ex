defmodule BfgCore do
  @moduledoc """
  Documentation for BfgCore.
  """

  alias BfgCore.Session.SessionProviderService

  defdelegate connect(url, port), to: SessionProviderService
end