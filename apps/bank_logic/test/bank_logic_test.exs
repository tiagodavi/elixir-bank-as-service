defmodule BankLogicTest do
  use ExUnit.Case, async: true

  alias BankLogic.Schemas.{Account}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    Sandbox.checkout(BankLogic.Repo)
    :ok
  end

  describe ".all" do
    test "returns empty list when there are no accounts" do
      assert {:ok, accounts} = BankLogic.all()
      assert accounts == []
    end

    test "returns items when there are accounts" do
      BankLogic.open()
      assert {:ok, accounts} = BankLogic.all()
      assert Enum.count(accounts) == 1
    end
  end

  describe ".open" do
    test "creates a new account with R$1000.00" do
      assert {:ok, %Account{} = account} = BankLogic.open()
      assert account.amount === %Money{amount: 100_000, currency: :BRL}
    end

    test "avoids duplicated accounts" do
      assert {:ok, %Account{} = account1} = BankLogic.open()
      assert {:ok, %Account{} = account2} = BankLogic.open()
      refute account1.number === account2.number
    end
  end

  describe ".balance" do
    test "error when one account does not exist" do
      assert {:error, msg} = BankLogic.balance(%{"number" => "000"})
      assert msg == "account does not exist"
    end

    test "returns balance" do
      {:ok, account} = BankLogic.open()
      assert {:ok, result} = BankLogic.balance(%{"number" => account.number})
      assert result.amount == %Money{amount: 100_000, currency: :BRL}
    end
  end

  describe ".transfer" do
    test "error when one of the accounts does not exist" do
      data = %{
        source: "16ec49e5",
        destination: "17ec49e5",
        amount: 10
      }

      assert {:error, msg} = BankLogic.transfer(data)
      assert msg == "one of the accounts does not exist"
    end

    test "error when accounts are equals" do
      data = %{
        source: "16ec49e5",
        destination: "16ec49e5",
        amount: 10
      }

      assert {:error, changeset} = BankLogic.transfer(data)
      assert changeset.errors == [accounts: {"source and destination are equals", []}]
    end

    test "error when there's no enough money" do
      {:ok, source} = BankLogic.open()
      {:ok, destination} = BankLogic.open()

      data = %{
        source: source.number,
        destination: destination.number,
        amount: 100_100
      }

      assert {:error, msg} = BankLogic.transfer(data)
      assert msg == "there's no enough money"
    end

    test "transfers money with success" do
      {:ok, source} = BankLogic.open()
      {:ok, destination} = BankLogic.open()

      data = %{
        source: source.number,
        destination: destination.number,
        amount: 75_00
      }

      assert {:ok, result} = BankLogic.transfer(data)
      assert result.amount === %Money{amount: 75_00, currency: :BRL}

      assert {:ok, source} = BankLogic.balance(%{number: source.number})
      assert {:ok, destination} = BankLogic.balance(%{number: destination.number})

      assert source.amount === %Money{amount: 92_500, currency: :BRL}
      assert destination.amount === %Money{amount: 107_500, currency: :BRL}
    end
  end

  describe ".cash_out" do
    test "error when account does not exist" do
      data = %{
        source: "16ec49e5",
        amount: 10
      }

      assert {:error, msg} = BankLogic.cash_out(data)
      assert msg == "account does not exist"
    end

    test "error when there's no enough money" do
      {:ok, source} = BankLogic.open()

      data = %{
        source: source.number,
        amount: 100_100
      }

      assert {:error, msg} = BankLogic.cash_out(data)
      assert msg == "there's no enough money"
    end

    test "cashs out with success" do
      {:ok, source} = BankLogic.open()

      data = %{
        source: source.number,
        amount: 10_080
      }

      assert {:ok, result} = BankLogic.cash_out(data)
      assert result.amount === %Money{amount: 10_080, currency: :BRL}

      assert {:ok, source} = BankLogic.balance(%{number: source.number})
      assert source.amount === %Money{amount: 89_920, currency: :BRL}
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
      assert transactions === %{report: [], total: %Money{amount: 0, currency: :BRL}}
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
      {:ok, source} = BankLogic.open()
      {:ok, destination} = BankLogic.open()

      data = %{
        source: source.number,
        destination: destination.number,
        amount: 10_000
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
      assert transactions.total === %Money{amount: 30_000, currency: :BRL}
      assert Enum.count(transactions.report) == 3
    end
  end
end
