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

    test "returns items when there are accounts" do
      BankLogic.open(%{email: "tiago.asp.net@gmail.com"})
      assert Enum.count(BankLogic.all()) == 1
    end
  end

  describe ".open" do
    test "creates a new account with $1000.00" do
      assert {:ok, %Account{} = account} = BankLogic.open(%{email: "tiago.asp.net@gmail.com"})
      assert account.email === "tiago.asp.net@gmail.com"
      assert account.amount === 1000.00
    end

    test "avoids duplicated accounts" do
      assert {:ok, %Account{} = account} = BankLogic.open(%{email: "tiago.asp.net@gmail.com"})
      assert {:error, changeset} = BankLogic.open(%{email: "tiago.asp.net@gmail.com"})
      assert changeset.errors == [email: {"has already been taken", []}]
    end
  end
end
