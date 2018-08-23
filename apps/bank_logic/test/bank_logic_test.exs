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

  describe ".transfer" do
    test "error when one of the accounts does not exist" do
      data = %{
        source: "email01@gmail.com",
        destination: "email02@gmail.com",
        amount: 10
      }

      assert {:error, msg} = BankLogic.transfer(data)
      assert msg == "one of the accounts does not exist"
    end

    test "error when accounts are equals" do
      data = %{
        source: "email01@gmail.com",
        destination: "email01@gmail.com",
        amount: 10
      }

      assert {:error, changeset} = BankLogic.transfer(data)
      assert changeset.errors == [accounts: {"source and destination are equals", []}]
    end

    test "error when there's no enough money" do
      BankLogic.open(%{email: "email01@gmail.com"})
      BankLogic.open(%{email: "email02@gmail.com"})

      data = %{
        source: "email01@gmail.com",
        destination: "email02@gmail.com",
        amount: 1001
      }

      assert {:error, msg} = BankLogic.transfer(data)
      assert msg == "there's no enough money"
    end

    test "transfers money with success" do
      BankLogic.open(%{email: "email01@gmail.com"})
      BankLogic.open(%{email: "email02@gmail.com"})

      data = %{
        source: "email01@gmail.com",
        destination: "email02@gmail.com",
        amount: 75
      }

      assert {:ok, result} = BankLogic.transfer(data)
      assert result == data
    end
  end
end
