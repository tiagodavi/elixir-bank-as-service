defmodule BankApiWeb.BankingView do
  use BankApiWeb, :view

  def render("index.json", %{accounts: accounts}) do
    %{accounts: accounts}
  end

  def render("open.json", %{email: email}) do
    %{email: email}
  end

  def render("account.json", %{account: account}) do
    %{account: account}
  end

  def render("report.json", %{report: report}) do
    %{report: report}
  end

  def render("transfer.json", %{amount: amount}) do
    %{amount: amount}
  end
end
