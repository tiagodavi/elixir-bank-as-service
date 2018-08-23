defmodule BankApiWeb.BankingController do
  @moduledoc """
  This is the main controller to access the entire api
  """

  use BankApiWeb, :controller

  action_fallback(BankApiWeb.FallBackController)

  def index(conn, _params) do
    render(conn, "index.json", %{accounts: BankLogic.all()})
  end

  def create(conn, params) do
    with {:ok, account} <- BankLogic.open(params) do
      render(conn, "account.json", %{account: account})
    end
  end
  
  def report(conn, _params) do
    render(conn, "report.json", %{report: BankLogic.report()})
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
