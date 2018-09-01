defmodule Nordnetex.Session.SessionSupervisor do
  use Supervisor
  require Logger

  @me __MODULE__

  def start_link(arg) do
    Logger.info("#{__MODULE__} started")
    Supervisor.start_link(@me, arg, name: @me)
  end

  @impl true
  def init(_arg) do
    children = [
      Nordnetex.Session.SessionManager
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
