defmodule Nordnetex.Stream.StreamConnectorProviderService do

  require Logger
  @behaviour Nordnetex.Stream.MarketStreamProvider

  @impl true
  def connect(host, port) do
    # packet line lets erlang buffer until /n, if large message is sent so that buffer is filled up
    # message will be truncated so make sure the buffer is larger than any message i can get, I have set the buffer
    # to the same size as the recbuf by inspecting using :ssl.getopts(socket, [:sndbuf, :recbuf, :buffer])}
    opts = [:binary, active: :once, packet: :line]
    {:ok, socket} = :ssl.connect(host, port, opts)
    {:ok, sizes} = :ssl.getopts(socket, [:sndbuf, :recbuf])
    {_, size} = Enum.max(sizes)
    :ssl.setopts(socket, buffer: size)
    Logger.info("Socket buffer size set to: #{inspect :ssl.getopts(socket, [:buffer])}")
    {:ok, socket}
  end

  @impl true
  def send(socket, data) do
    :ssl.send(socket, Poison.encode!(data) <> "\n")
  end

  @impl true
  def close(socket) do
    :ssl.close(socket)
  end

  @impl true
  def setopts(socket) do
    # Reactivate socket to recive next message
    :ssl.setopts(socket, active: :once)
  end
end