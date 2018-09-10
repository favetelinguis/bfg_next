defmodule BfgCore.Stream.PublicEventHandler do

    @callback handle_price(event :: map) :: none

    @callback handle_news(event :: map) :: none
end