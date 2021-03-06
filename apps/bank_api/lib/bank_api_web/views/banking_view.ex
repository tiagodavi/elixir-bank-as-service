defmodule BankApiWeb.BankingView do
  use BankApiWeb, :view

  def render("accounts.json", %{accounts: accounts}) do
    render_many(accounts, BankApiWeb.BankingView, "account.json", as: :account)
  end

  def render("account.json", %{account: account}) do
    %{id: account.id, number: account.number, amount: to_string(account.amount)}
  end

  def render("transactions.json", %{transactions: transactions}) do
    %{
      report:
        render_many(transactions.report, BankApiWeb.BankingView, "transaction.json",
          as: :transaction
        ),
      total: to_string(transactions.total)
    }
  end

  def render("statements.json", %{statements: statements}) do
    Enum.map(statements, fn s ->
      %{
        amount: to_string(s.amount),
        balance: to_string(s.balance),
        operation: s.operation
      }
    end)
  end

  def render("transaction.json", %{transaction: transaction}) do
    data = %{
      operation: transaction.operation,
      source: transaction.source,
      amount: to_string(transaction.amount)
    }

    if transaction[:destination] do
      Map.put_new(data, :destination, transaction.destination)
    else
      data
    end
  end
end
