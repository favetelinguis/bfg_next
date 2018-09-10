defmodule BfgBotTest do
  use ExUnit.Case
  doctest BfgBot

  test "greets the world" do
    assert BfgBot.hello() == :world
  end
end
