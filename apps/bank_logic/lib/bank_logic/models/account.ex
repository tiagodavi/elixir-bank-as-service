defmodule BankLogic.Models.Account do
  @moduledoc """
  Account Model to handle business rules
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias BankLogic.Repo
  alias BankLogic.Schemas.{Account, Transaction}

  def all() do
    query =
      from(c in Account,
        select: c
      )

    Repo.all(query)
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
        {:ok, _} -> {:ok, %{source: source.email, amount: amount}}
        _ -> {:error, "something has been wrong. please try again."}
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
        {:ok, _} -> {:ok, %{source: source.email, destination: destination.email, amount: amount}}
        _ -> {:error, "something has been wrong. please try again."}
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

  # def info(phone_number, period \\ nil) do
  #   query =
  #     from(
  #       t0 in TelephoneCall,
  #       join: t1 in TelephoneCall,
  #       on: t0.call_id == t1.call_id,
  #       select: %{
  #         destination: t0.destination,
  #         call_start: t0.timestamp,
  #         rule_id: t0.rule_id,
  #         call_end: t1.timestamp
  #       },
  #       where: t0.source == ^phone_number,
  #       where: t0.type == "start",
  #       where: t1.type == "end"
  #     )
  #
  #   if period do
  #     [month, year] = String.split(period, "/")
  #     month = String.to_integer(month)
  #     year = String.to_integer(year)
  #
  #     q =
  #       from(
  #         [_, t1] in query,
  #         where: fragment("EXTRACT(MONTH FROM ?)", t1.timestamp) == ^month,
  #         where: fragment("EXTRACT(YEAR FROM ?)", t1.timestamp) == ^year
  #       )
  #
  #     Repo.all(q)
  #   else
  #     previous =
  #       NaiveDateTime.utc_now()
  #       |> NaiveDateTime.add(-2_592_000)
  #
  #     q =
  #       from(
  #         [_, t1] in query,
  #         where: fragment("EXTRACT(MONTH FROM ?)", t1.timestamp) == ^previous.month,
  #         where: fragment("EXTRACT(YEAR FROM ?)", t1.timestamp) == ^previous.year
  #       )
  #
  #     Repo.all(q)
  #   end
  # end
end
