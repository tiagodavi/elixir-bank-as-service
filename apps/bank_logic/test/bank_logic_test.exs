defmodule BankLogicTest do
  use ExUnit.Case
  doctest BankLogic

  test "greets the world" do
    assert BankLogic.hello() == :world
  end
end
