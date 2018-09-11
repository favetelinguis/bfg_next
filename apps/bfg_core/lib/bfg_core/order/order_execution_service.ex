defmodule BfgCore.Order.OrderExecutionService do
  use GenServer
  @me __MODULE__

  alias BfgCore.Account.AccountInfoService
  alias BfgCore.Order.PreOrderValidationService
  alias BfgCore.Order
  @order_management_provider Application.get_env(:bfg_core, :order_management_provider)

  ############################################################
  # Client
  ############################################################
  def start_link(args), do: GenServer.start_link(@me, args, name: @me)
  def execute_trade_signal(trade_signal), do: GenServer.cast(@me, {:execute_order, trade_signal})

  ############################################################
  # Callbacks
  ############################################################
  def init(_) do
    {:ok, nil}
  end

  def handle_cast({:execute_order, trade_signal}, state) do
    with :ok <- PreOrderValidationService.validate(trade_signal),
         [account | _] <- AccountInfoService.find_accounts_to_trade(),
         order <- Order.new(trade_signal) do
      @order_management_provider.place_order(order)
    end
  end

  ############################################################
  # Impl
  ############################################################
end
