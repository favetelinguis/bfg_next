defmodule Nordnetex.Order.OrderManagementProviderService do 
    require Logger
    import Nordnetex.Session.SessionManager, only: [get: 1, post: 2, delete: 1, put: 2]
    alias Nordnetex.Account.AccountDataProviderService 
    alias BfgCore.Order

    @behaviour BfgCore.Order.OrderManagementProvider

    @impl true
    def pending_orders_for_account(account_id) do
        {:ok, response} = get("/accounts/#{account_id}/orders?deleted=false")

        response
        |> Enum.map(&map_to_order/1)
    end

    @impl true
    def place_order(order, account_id) do
        url = "/accounts/#{account_id}/orders"
        body = %{
            "identifier" => order.instrument.instrument_id,
            "market_id" => order.instrument.market_id,
            "price" => order.price,
            "volume" => order.units,
            "side" => order.side,
            "order_type" => order.order_type,
            }
        {:ok, response} = post(url, body)
        response #TODO i should map to BfgCore type
    end

    @impl true
    def close_order(order_id, account_id) do
        {:ok, response} = delete("/accounts/#{account_id}/orders/#{order_id}")
        response #TODO i should map to BfgCore type
    end

    defp map_to_order(order) do
        Order.new_limit_order_with_targets(order["tradable"], order["volume"], order["side"], order["order_type"], order["take_profit"], order["stop_loss"], order["price"])
        |> Map.put(:order_id, order["order_id"])
    end
end