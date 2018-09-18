defmodule BankLogicTest do
  use ExUnit.Case, async: true

  @transfer BankLogic.Schemas.Transaction.operations().transfer
  @cash_out BankLogic.Schemas.Transaction.operations().cash_out

  alias BankLogic.Schemas.{Account}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(BankLogic.Repo)
    :ok
  end

  describe ".all" do
    test "returns empty list when there are no accounts" do
      assert {:ok, accounts} = BankLogic.all()
      assert accounts == []
    end

    test "returns items when there are accounts" do
      BankLogic.open(%{email: "tiago.asp.net@gmail.com"})
      assert {:ok, accounts} = BankLogic.all()
      assert Enum.count(accounts) == 1
    end
  end

  describe ".open" do
    @tag :run
    test "creates a new account with $1000.00" do
      assert {:ok, %Account{} = account} = BankLogic.open()

      IO.inspect account
      assert account.amount === 1000_00
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
        amount: 75,
        operation: @transfer
      }

      assert {:ok, result} = BankLogic.transfer(data)
      assert result == data
    end
  end

  describe ".cash_out" do
    test "error when account does not exist" do
      data = %{
        source: "email01@gmail.com",
        amount: 10
      }

      assert {:error, msg} = BankLogic.cash_out(data)

      assert msg == "account does not exist"
    end

    test "error when there's no enough money" do
      BankLogic.open(%{email: "email01@gmail.com"})

      data = %{
        source: "email01@gmail.com",
        amount: 1001
      }

      assert {:error, msg} = BankLogic.cash_out(data)
      assert msg == "there's no enough money"
    end

    test "cashs out with success" do
      BankLogic.open(%{email: "email01@gmail.com"})

      data = %{
        source: "email01@gmail.com",
        amount: 100,
        operation: @cash_out
      }

      assert {:ok, result} = BankLogic.cash_out(data)
      assert result == data
    end
  end

  describe ".report" do
    test "returns empty list when there are no accounts" do
      start_date =
        Date.utc_today()
        |> Date.to_string()

      end_date =
        Date.utc_today()
        |> Date.add(2)
        |> Date.to_string()

      assert {:ok, transactions} = BankLogic.report(%{start_date: start_date, end_date: end_date})

      assert transactions == %{total: 0, report: []}
    end

    test "start_date can't be greater or equal than end_date" do
      start_date =
        Date.utc_today()
        |> Date.add(1)
        |> Date.to_string()

      end_date =
        Date.utc_today()
        |> Date.to_string()

      assert {:error, changeset} = BankLogic.report(%{start_date: start_date, end_date: end_date})
      assert changeset.errors == [dates: {"start_date is greater or equal than end_date", []}]
    end

    test "returns report" do
      BankLogic.open(%{email: "email01@gmail.com"})
      BankLogic.open(%{email: "email02@gmail.com"})

      data = %{
        source: "email01@gmail.com",
        destination: "email02@gmail.com",
        amount: 100
      }

      assert {:ok, _} = BankLogic.transfer(data)
      assert {:ok, _} = BankLogic.transfer(data)
      assert {:ok, _} = BankLogic.cash_out(data)

      start_date =
        Date.utc_today()
        |> Date.to_string()

      end_date =
        Date.utc_today()
        |> Date.add(1)
        |> Date.to_string()

      assert {:ok, transactions} = BankLogic.report(%{start_date: start_date, end_date: end_date})
      assert transactions.total == 300.00
      assert Enum.count(transactions.report) == 3
    end
  end
end
