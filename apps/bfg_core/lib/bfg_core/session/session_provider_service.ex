defmodule BfgCore.Session.SessionProviderService do
  @moduledoc """
  Documentation for BfgCore.
  """

  @session_provider Application.get_env(:bfg_core, :session_provider)

  @doc """
  Hello world.

  ## Examples

      iex> :world
      :world

  """
  def connect(private_feed_event_handler, public_feed_event_handler) do
    @session_provider.connect(private_feed_event_handler, public_feed_event_handler)
  end
end
