defmodule BankLogicTest do
  use ExUnit.Case, async: true

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(BankLogic.Repo)
    :ok
  end

  describe ".all" do
    test "returns empty list when there are no accounts" do
      assert BankLogic.all() == []
    end
  end
end
