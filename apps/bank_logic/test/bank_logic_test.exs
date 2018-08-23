defmodule BankLogicTest do
  use ExUnit.Case, async: true

  alias BankLogic.Schemas.{Account}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(BankLogic.Repo)
    :ok
  end

  describe ".all" do
    test "returns empty list when there are no accounts" do
      assert BankLogic.all() == []
    end
  end

  describe ".open" do
    test "creates a new account" do
      assert {:ok, %Account{} = account} = BankLogic.open(%{email: "tiago.asp.net@gmail.com"})
      assert account.email === "tiago.asp.net@gmail.com"
      assert account.amount === 1000.00
    end
  end
end
