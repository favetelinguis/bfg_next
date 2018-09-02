defmodule BfgCoreTest do
  use ExUnit.Case
  doctest BfgCore

  test "greets the world" do
    assert BfgCore.hello() == :world
  end
end
