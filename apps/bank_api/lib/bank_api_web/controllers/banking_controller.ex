defmodule BankApiWeb.BankingController do
  @moduledoc """
  This is the main controller to access the entire api
  """

  use BankApiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.json", %{accounts: BankLogic.all()})
  end

  def open(conn, %{"email" => email}) do
    case BankLogic.open(email) do
      {:ok, email} ->
        render(conn, "open.json", %{email: email})

      {:error, reason} ->
        render(conn, "error.json", %{error: reason})
    end
  end

  def info(conn, %{"email" => email}) do
    case BankLogic.info(email) do
      {:ok, account} ->
        render(conn, "account.json", %{account: account})

      {:error, reason} ->
        render(conn, "error.json", %{error: reason})
    end
  end

  def report(conn, _params) do
    render(conn, "report.json", %{report: BankLogic.report()})
  end

  def transfer(conn, params) do
    {amount, _} = Float.parse(params["amount"])

    case BankLogic.transfer(
           params["source"],
           params["destination"],
           amount
         ) do
      {:ok, amount} ->
        render(conn, "transfer.json", %{amount: amount})

      {:error, reason} ->
        render(conn, "error.json", %{error: reason})
    end
  end

  def cash_out(conn, params) do
    {amount, _} = Float.parse(params["amount"])

    case BankLogic.cash_out(
           params["email"],
           amount
         ) do
      {:ok, amount} ->
        render(conn, "transfer.json", %{amount: amount})

      {:error, reason} ->
        render(conn, "error.json", %{error: reason})
    end
  end
end
