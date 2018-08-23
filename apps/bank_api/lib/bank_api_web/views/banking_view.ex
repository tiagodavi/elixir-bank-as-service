defmodule BankApiWeb.BankingView do
  use BankApiWeb, :view

  def render("index.json", %{accounts: accounts}) do
    %{data: render_many(accounts, BankApiWeb.BankingView, "account.json", as: :account)}
  end

  def render("account.json", %{account: account}) do
    %{id: account.id, email: account.email, amount: account.amount}
  end

  def render("account.json", %{account: account}) do
    %{account: account}
  end

  def render("report.json", %{report: report}) do
    %{report: report}
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{
      source: transaction.source,
      destination: transaction.destination,
      amount: transaction.amount
    }
  end
end
