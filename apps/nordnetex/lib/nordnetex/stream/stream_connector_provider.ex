defmodule Nordnetex.Stream.StreamConnectorProvider do
  @callback connect(host :: any, port :: any) :: any

  @callback send(socket :: any, data :: any) :: any

  @callback close(socket :: any) :: any

  @callback setopts(socket :: any) :: any
end
