defmodule BankApiWeb.BankingView do
  use BankApiWeb, :view

  def render("accounts.json", %{accounts: accounts}) do
    %{data: render_many(accounts, BankApiWeb.BankingView, "account.json", as: :account)}
  end

  def render("account.json", %{account: account}) do
    %{id: account.id, email: account.email, amount: Float.round(account.amount, 2)}
  end

  def render("transactions.json", %{transactions: transactions}) do
    %{
      data: %{
        report:
          render_many(transactions.report, BankApiWeb.BankingView, "transaction.json",
            as: :transaction
          ),
        total: Float.round(transactions.total, 2)
      }
    }
  end

  def render("transaction.json", %{transaction: transaction}) do
    data = %{
      operation: transaction.operation,
      source: transaction.source,
      amount: Float.round(transaction.amount, 2)
    }

    if transaction[:destination] do
      Map.put_new(data, :destination, transaction.destination)
    else
      data
    end
  end
end
