defmodule Nordnetex.Stream.OrderStreamMessageHub do
  @moduledoc """
  This modules only purpose is to offload all the work from the stream connecton and instead do it here
  so that the stream connection is as fast as possible.

  Right now the implementation is minimal be we could also move handle heartbeat here and parse the message here
  """
  use GenServer
  require Logger

  @cache nil

  @me __MODULE__

  def handle_message(msg), do: GenServer.cast(@me, {:handle_message, msg})

  def start_link(event_handler) do
    GenServer.start_link(@me, event_handler, name: @me)
  end

  def init(event_handler) do
    {:ok, event_handler}
  end

  @doc """
  """
  def handle_cast({:handle_message, msg}, event_handler) do
    #TODO should convert to BfgCore types before sending data
    case Poison.Parser.parse!(msg) do
      %{"type" => "heartbeat"} -> Logger.debug("Order stream Got heartbeat")
      %{"type" => "order"} = message -> event_handler.handle_order(message["data"])
      %{"type" => "trade"} = message -> event_handler.handle_trade(message["data"])
      message -> Logger.warn("In handle message catch all and got #{inspect(message)}")
    end

    {:noreply, event_handler}
  end
end
