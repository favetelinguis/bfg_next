defmodule Nordnetex.Stream.SubscriptionManager do
  @moduledoc false
  require Logger
  @me __MODULE__

  def start_link() do
    Logger.info("#{@me} started")

    DynamicSupervisor.start_link(
      name: @me,
      strategy: :one_for_one
    )
  end

  def child_spec(_arg) do
    %{
      id: @me,
      start: {@me, :start_link, []},
      type: :supervisor
    }
  end

  def subscribe_market_stream(session_token, connection_details) do
    DynamicSupervisor.start_child(
      @me,
      {Nordnetex.Stream.MarketStreamProviderService, {session_token, connection_details}}
    )
  end

  def subscribe_order_stream(session_token, connection_details) do
    DynamicSupervisor.start_child(
      @me,
      {Nordnetex.Stream.OrderStream, {session_token, connection_details}}
    )
  end
end
