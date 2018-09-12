defmodule BfgBot.Strategy.StrategyCache do
  @moduledoc false
  require Logger
  @me __MODULE__

  def start_link() do
    Logger.info("Starting #{@me}")

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

  @doc """
  Returns the pid of the started process
  """
  def server_process(market_and_identifier) do
    case start_child(market_and_identifier) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def start_child(market_and_identifier) do
    DynamicSupervisor.start_child(
      @me,
      {BfgBot.Strategy.StrategyServer, market_and_identifier}
    )
  end
end
