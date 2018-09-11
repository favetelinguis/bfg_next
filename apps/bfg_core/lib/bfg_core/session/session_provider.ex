defmodule BfgCore.Session.SessionProvider do
  @callback connect(privat_feed_event_handler :: atom, public_feed_event_handler :: atom) :: none
end
