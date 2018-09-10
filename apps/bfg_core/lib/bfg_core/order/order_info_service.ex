defmodule BfgCore.Order.OrderInfoService do
    @moduledoc """
    Provides the read operations for orders
    """
    require Logger

    @order_management_provider Application.get_env(:bfg_core, :order_management_provider)

    def all_pending_orders() do
        @order_management_provider.all_pending_orders()
    end

    def pending_orders_for_account(account_id) do
        @order_management_provider.pending_orders_for_account(account_id)
    end

    def pending_orders_for_instrument(instrument) do
        @order_management_provider.pending_orders_for_instrument(instrument)
    end

    def pending_order_for_account(order_id, account_id) do
        @order_management_provider.pending_order_for_account(order_id, account_id)
    end

    def find_net_position_count_for_currency(currency) do
        nil # TODO should fix this
        # Looks like only needed for currency trading?
    end
end