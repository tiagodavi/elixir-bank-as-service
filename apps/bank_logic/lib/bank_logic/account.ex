defmodule BankLogic.Account do
  @moduledoc """
  Account Module to handle business rules
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias BankLogic.Repo
  alias BankLogic.Schemas.{Account, Transaction}
  alias Ecto.{Multi, UUID}

  def report(attrs) do
    changeset = Transaction.report_changeset(attrs)

    if changeset.valid? do
      build_report(get_change(changeset, :start_date), get_change(changeset, :end_date))
    else
      {:error, changeset}
    end
  end

  def all do
    query =
      from(c in Account,
        select: c
      )

    {:ok, Repo.all(query)}
  end

  def create do
    number =
      UUID.generate()
      |> String.slice(0, 8)

    with {:ok, account} <-
           %Account{}
           |> Account.create_changeset(%{number: number})
           |> Repo.insert() do
      {:ok, account}
    else
      {:error, _changeset} -> create()
    end
  end

  def balance(%{"number" => number}), do: get_balance(number)
  def balance(%{number: number}), do: get_balance(number)
  def balance(_), do: get_balance("")

  def cash_out(attrs) do
    with %Ecto.Changeset{valid?: true} = changeset <- Account.cash_out_changeset(attrs),
         %Account{} = source <- get_by(number: get_change(changeset, :source)) do
      try_cash_out(source, get_change(changeset, :amount))
    else
      %Ecto.Changeset{valid?: false} = changeset -> {:error, changeset}
      _ -> {:error, "account does not exist"}
    end
  end

  defp try_cash_out(_source, %Money{amount: 0, currency: :BRL}) do
    {:error, "You can't cash out R$0,00"}
  end

  defp try_cash_out(source, amount) do
    if source.amount.amount >= amount.amount do
      Multi.new()
      |> Multi.update(:source, change(source, amount: Money.subtract(source.amount, amount)))
      |> Multi.insert(:transaction, build_transaction(source, amount))
      |> Repo.transaction()
      |> case do
        {:ok, _} ->
          {:ok,
           %{source: source.number, amount: amount, operation: Transaction.operations().cash_out}}

        _ ->
          {:error, "something has been wrong. please try again."}
      end
    else
      {:error, "there's no enough money"}
    end
  end

  def transfer(attrs) do
    with %Ecto.Changeset{valid?: true} = changeset <- Account.transfer_changeset(attrs),
         %Account{} = source <- get_by(number: get_change(changeset, :source)),
         %Account{} = destination <- get_by(number: get_change(changeset, :destination)) do
      try_transfer(source, destination, get_change(changeset, :amount))
    else
      %Ecto.Changeset{valid?: false} = changeset -> {:error, changeset}
      _ -> {:error, "one of the accounts does not exist"}
    end
  end

  defp try_transfer(_source, _destination, %Money{amount: 0, currency: :BRL}) do
    {:error, "You can't transfer R$0,00"}
  end

  defp try_transfer(source, destination, amount) do
    if source.amount.amount >= amount.amount do
      Multi.new()
      |> Multi.update(:source, change(source, amount: Money.subtract(source.amount, amount)))
      |> Multi.update(
        :destination,
        change(destination, amount: Money.add(destination.amount, amount))
      )
      |> Multi.insert(:transaction, build_transaction(source, destination, amount))
      |> Repo.transaction()
      |> case do
        {:ok, _} ->
          {:ok,
           %{
             source: source.number,
             destination: destination.number,
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
        select: %{
          amount: t.amount,
          source: s.number,
          destination: d.number,
          operation: t.operation
        }
      )

    transactions = Repo.all(query)

    total =
      transactions
      |> Enum.reduce(Money.new(0), fn %{amount: amount}, acc -> Money.add(acc, amount) end)

    {:ok, %{report: transactions, total: total}}
  end

  defp get_balance(number) do
    with %Account{} = account <- get_by(number: number) do
      {:ok, account}
    else
      _ -> {:error, "account does not exist"}
    end
  end

  defp get_by(conditions) do
    Repo.get_by(Account, conditions)
  end
end
