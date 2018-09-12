defmodule Nordnetex.Stream.MarketStreamProviderServiceTest do
    use ExUnit.Case, async: true
    alias Nordnetex.Stream.MarketStreamProviderService, as: Subject
  
    import Mox
  
    setup [:set_mox_global, :verify_on_exit!]

    test "connect is called at startup" do 
        Nordnetex.Stream.StreamConnectorProviderServiceMock
        |> expect(:connect, fn address, port -> {:ok, "socket"} end)
        |> expect(:send, fn socket, data -> :ok end)

        Subject.start_link({"adfa", {'host', 4444}})
        # The connection is async so i need to wait
        Process.sleep(2000)
    end
end