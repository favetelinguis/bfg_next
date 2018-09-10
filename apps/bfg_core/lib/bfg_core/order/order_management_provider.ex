defmodule BfgCore.Order.OrderManagementProvider do
    @moduledoc """ 
    A provider of CRUD operations for an instrument Order. An order is normally 
    placed for a given instrument and/or an accountId. An accountId may not be 
    required if only a single account is allowed by the platform provider, in 
    which case all orders are created under the default account.
    """

    @doc """ 
    An order is normally of types market or limit. A market order is executed
	straight away by the platform whilst a limit order is executed only if
	the limit price is hit. Therefore for a limit order this method may not
	return an orderId.
    """
    @callback place_order(order :: map, account_id :: integer) :: none

    @doc """ 
    Modify the attributes of a given order. The platform may only permit to
	modify attributes like limit price, stop loss, take profit, expiration
	date, units.
    """
    @callback modify_order(order :: map, account_id :: integer) :: none

    @doc """ 
    Effectively cancel the order if it is waiting to be executed. A valid
	orderId and an optional accountId may be required to uniquely identify an
	order to close/cancel.
    """
    @callback close_order(order_id :: integer, account_id :: integer) :: none
    
    @doc """
    return a collection of all pending orders across all accounts
    """
    @callback all_pending_orders :: [map]
    
    @doc """
    return a collection of all pending orders for a given account
    """
    @callback pending_orders_for_account(account_id :: integer) :: [map]

    @doc """
    return a pending order
    """
    @callback pending_order_for_account(order_id :: integer, account_id :: integer) :: map

    @doc """
    return all pending orders for a instrument for a given account
    """
    @callback pending_orders_for_instrument(instrument :: map) :: [map]
end