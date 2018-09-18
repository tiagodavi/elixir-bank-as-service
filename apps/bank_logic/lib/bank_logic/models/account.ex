defmodule BankLogic.Models.Account do
  @moduledoc """
  Account Model to handle business rules
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias BankLogic.Repo
  alias BankLogic.Schemas.{Account, Transaction}

  def report(attrs) do
    changeset = Transaction.report_changeset(attrs)

    if changeset.valid? do
      build_report(get_change(changeset, :start_date), get_change(changeset, :end_date))
    else
      {:error, changeset}
    end
  end

  defp build_report(start_date, end_date) do
    {:ok, start_date} =
      start_date
      |> NaiveDateTime.new(~T[00:00:00.000])

    {:ok, end_date} =
      end_date
      |> NaiveDateTime.new(~T[23:59:59.000])

    query =
      from(t in Transaction,
        left_join: s in Account,
        on: s.id == t.source_id,
        left_join: d in Account,
        on: d.id == t.destination_id,
        where: t.inserted_at >= ^start_date,
        where: t.inserted_at <= ^end_date,
        select: %{amount: t.amount, source: s.email, destination: d.email, operation: t.operation}
      )

    transactions = Repo.all(query)

    total =
      transactions
      |> Enum.reduce(0.0, fn %{amount: amount}, acc -> amount + acc end)

    {:ok, %{report: transactions, total: total}}
  end

  def all do
    query =
      from(c in Account,
        select: c
      )

    {:ok, Repo.all(query)}
  end

  def create_account(attrs) do
    %Account{}
    |> Account.create_account_changeset(attrs)
    |> Repo.insert()
  end

  def cash_out(attrs) do
    changeset = Account.cash_out_changeset(attrs)

    if changeset.valid? do
      source = get_by(email: get_change(changeset, :source))

      if source do
        try_cash_out(source, get_change(changeset, :amount))
      else
        {:error, "account does not exist"}
      end
    else
      {:error, changeset}
    end
  end

  defp try_cash_out(source, amount) do
    if source.amount >= amount do
      Ecto.Multi.new()
      |> Ecto.Multi.update(:source, change(source, amount: source.amount - amount))
      |> Ecto.Multi.insert(:transaction, build_transaction(source, amount))
      |> Repo.transaction()
      |> case do
        {:ok, _} ->
          {:ok,
           %{source: source.email, amount: amount, operation: Transaction.operations().cash_out}}

        _ ->
          {:error, "something has been wrong. please try again."}
      end
    else
      {:error, "there's no enough money"}
    end
  end

  def transfer(attrs) do
    changeset = Account.transfer_changeset(attrs)

    if changeset.valid? do
      source = get_by(email: get_change(changeset, :source))
      destination = get_by(email: get_change(changeset, :destination))

      if source && destination do
        try_transfer(source, destination, get_change(changeset, :amount))
      else
        {:error, "one of the accounts does not exist"}
      end
    else
      {:error, changeset}
    end
  end

  defp try_transfer(source, destination, amount) do
    if source.amount >= amount do
      Ecto.Multi.new()
      |> Ecto.Multi.update(:source, change(source, amount: source.amount - amount))
      |> Ecto.Multi.update(:destination, change(destination, amount: destination.amount + amount))
      |> Ecto.Multi.insert(:transaction, build_transaction(source, destination, amount))
      |> Repo.transaction()
      |> case do
        {:ok, _} ->
          {:ok,
           %{
             source: source.email,
             destination: destination.email,
             amount: amount,
             operation: Transaction.operations().transfer
           }}

        _ ->
          {:error, "something has been wrong. please try again."}
      end
    else
      {:error, "there's no enough money"}
    end
  end

  defp build_transaction(source, destination, amount) do
    %Transaction{
      operation: Transaction.operations().transfer,
      source_id: source.id,
      destination_id: destination.id,
      amount: amount
    }
  end

  defp build_transaction(source, amount) do
    %Transaction{
      operation: Transaction.operations().cash_out,
      source_id: source.id,
      amount: amount
    }
  end

  defp get_by(conditions) do
    Repo.get_by(Account, conditions)
  end
end
