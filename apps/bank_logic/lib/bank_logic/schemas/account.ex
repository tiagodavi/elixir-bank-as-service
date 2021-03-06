defmodule BankLogic.Schemas.Account do
  @moduledoc """
  Account Schema to handle validations
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field(:number, :string)
    field(:amount, Money.Ecto.Type)
    timestamps()
  end

  def create_changeset(account, attrs) do
    account
    |> cast(attrs, [:number])
    |> validate_required([:number])
    |> unique_constraint(:number)
    |> add_default_amount
  end

  def transfer_changeset(attrs) do
    data = %{}
    types = %{source: :string, destination: :string, amount: Money.Ecto.Type}

    {data, types}
    |> cast(attrs, Map.keys(types))
    |> validate_required(Map.keys(types))
    |> validate_source_destination
  end

  def cash_out_changeset(attrs) do
    data = %{}
    types = %{source: :string, amount: Money.Ecto.Type}

    {data, types}
    |> cast(attrs, Map.keys(types))
    |> validate_required(Map.keys(types))
  end

  defp add_default_amount(changeset) do
    changeset
    |> put_change(:amount, Money.new(100_000))
  end

  defp validate_source_destination(changeset) do
    source = get_change(changeset, :source)
    destination = get_change(changeset, :destination)

    case source do
      ^destination -> add_error(changeset, :accounts, "source and destination are equals")
      _ -> changeset
    end
  end
end
