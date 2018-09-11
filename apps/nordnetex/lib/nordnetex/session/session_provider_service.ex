defmodule Nordnetex.Session.SessionProviderService do
  require Logger

  @behaviour BfgCore.Session.SessionProvider
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

  @impl true
  def connect(private_event_handler, public_event_handler) do
    DynamicSupervisor.start_child(
      @me,
      {Nordnetex.Stream.MarketStreamMessageHub, public_event_handler}
    )

    DynamicSupervisor.start_child(
      @me,
      {Nordnetex.Stream.OrderStreamMessageHub, private_event_handler}
    )

    DynamicSupervisor.start_child(
      @me,
      Nordnetex.Session.SessionSupervisor
    )
  end
end
