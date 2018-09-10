defmodule BfgCore.Stream.PrivateEventHandler do
    
    @callback handle_order(event :: map) :: none

    @callback handle_trade(event :: map) :: none
end