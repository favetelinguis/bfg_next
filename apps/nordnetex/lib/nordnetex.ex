defmodule Nordnetex do
  @moduledoc """
  Documentation for Nordnetex.
  """
  require Logger

  import Nordnetex.Session.SessionManager, only: [get: 2]

  @doc """
  Returns a list of accounts that the user has access to
  """
  def accounts() do
    get("/accounts", %{})
  end
end
