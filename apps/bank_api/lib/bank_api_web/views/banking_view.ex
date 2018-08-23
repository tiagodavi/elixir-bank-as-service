defmodule BankApiWeb.BankingView do
  use BankApiWeb, :view

  def render("accounts.json", %{accounts: accounts}) do
    %{data: render_many(accounts, BankApiWeb.BankingView, "account.json", as: :account)}
  end

  def render("account.json", %{account: account}) do
    %{id: account.id, email: account.email, amount: account.amount}
  end

  def render("transactions.json", %{transactions: transactions}) do
    %{
      data: %{
        report:
          render_many(transactions.report, BankApiWeb.BankingView, "transaction.json",
            as: :transaction
          ),
        total: transactions.total
      }
    }
  end

  def render("transaction.json", %{transaction: transaction}) do
    data = %{
      operation: transaction.operation,
      source: transaction.source,
      amount: transaction.amount
    }

    if transaction[:destination] do
      Map.put_new(data, :destination, transaction.destination)
    else
      data
    end
  end
end
