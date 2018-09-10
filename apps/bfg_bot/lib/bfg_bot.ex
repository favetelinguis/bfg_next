defmodule BfgBot do
  @moduledoc """
  Documentation for BfgBot.
  """

  @doc """
  Hello world.

  ## Examples

      iex> BfgBot.hello
      :world

  """
  def start do
    BfgCore.connect(BfgBot.EventHandler.PrivateEventHandler, BfgBot.EventHandler.PublicEventHandler)
  end
end
