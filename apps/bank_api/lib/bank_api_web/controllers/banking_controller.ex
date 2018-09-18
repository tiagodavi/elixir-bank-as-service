defmodule BankApiWeb.BankingController do
  @moduledoc """
  This is the main controller to access the entire api
  """

  use BankApiWeb, :controller

  action_fallback(BankApiWeb.FallBackController)

  def index(conn, _params) do
    with {:ok, accounts} <- BankLogic.all() do
      render(conn, "accounts.json", %{accounts: accounts})
    end
  end

  def create(conn, _params) do
    with {:ok, account} <- BankLogic.open() do
      render(conn, "account.json", %{account: account})
    end
  end

  def report(conn, params) do
    with {:ok, transactions} <- BankLogic.report(params) do
      render(conn, "transactions.json", %{transactions: transactions})
    end
  end

  def transfer(conn, params) do
    with {:ok, transaction} <- BankLogic.transfer(params) do
      render(conn, "transaction.json", %{transaction: transaction})
    end
  end

  def cash_out(conn, params) do
    with {:ok, transaction} <- BankLogic.cash_out(params) do
      render(conn, "transaction.json", %{transaction: transaction})
    end
  end
end
