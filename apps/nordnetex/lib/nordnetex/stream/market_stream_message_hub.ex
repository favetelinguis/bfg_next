defmodule Nordnetex.Stream.MarketStreamMessageHub do
  @moduledoc """
  This modules only purpose is to offload all the work from the stream connecton and instead do it here
  so that the stream connection is as fast as possible.

  Right now the implementation is minimal be we could also move handle heartbeat here and parse the message here
  """
  use GenServer
  require Logger

  @price_handler nil
  @news_handler nil

  @me __MODULE__

  def handle_message(msg), do: GenServer.cast(@me, {:handle_message, msg})

  def start_link(_) do
    GenServer.start_link(@me, nil, name: @me)
  end

  def init(_) do
    {:ok, nil}
  end

  @doc """
  price
  %{"data" => %{"ask" => 0.0, "ask_volume" => 0, "bid" => 71.64, "bid_volume" =>248849, "close" => 72.0, "high" => 73.0, "i" => "101", "last" => 71.08, "last_volume" => 482, "low" => 45.0, "m"=> 11, "open" => 72.0, "tick_timestamp" => 1536352607679, "trade_timestamp" => 1536350402059, "turnover" => 663049.46, "turnover_volume" => 9262, "vwap" => 71.58}, "type" => "price"}
  heartbeat
  %{"data" => %{}, "type" => "heartbeat"}
  err
  %{"data" => %{"cmd" => %{"args" => %{"s" => 2, "t" => "news"}, "cmd" => "subscribe"}, "msg" => "Not authorized."}, "type" => "err"}
  """
  def handle_cast({:handle_message, msg}, state) do
    case Poison.Parser.parse!(msg) do
      %{"type" => "heartbeat"} -> Logger.debug("Market stream Got heartbeat")
      %{"type" => "price"} = message -> Logger.info("Got price: #{inspect(message["data"])}")
      %{"type" => "news"} = message -> Logger.info("Got news: #{inspect(message["data"])}")
      message -> Logger.warn("In handle message catch all and got #{inspect(message)}")
    end

    {:noreply, state}
  end
end
