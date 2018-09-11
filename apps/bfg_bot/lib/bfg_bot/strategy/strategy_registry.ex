defmodule BfgBot.Strategy.StrategyRegistry do
  @moduledoc false
  require Logger
  @me __MODULE__

  def start_link do
    Logger.info("Starting #{@me}")
    Registry.start_link(keys: :unique, name: @me)
  end

  def via_tuple(key) do
    {:via, Registry, {@me, key}}
  end

  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: @me,
      start: {@me, :start_link, []}
    )
  end
end
