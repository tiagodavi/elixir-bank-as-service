defmodule BankLogic.Schemas.Account do
  @moduledoc """
  Account Schema to handle validations
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field(:email, :string)
    field(:amount, :float)
    timestamps()
  end

  def create_account_changeset(account, attrs) do
    account
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> add_default_amount
  end

  def transfer_changeset(attrs) do
    data = %{}
    types = %{source: :string, destination: :string, amount: :float}

    {data, types}
    |> cast(attrs, Map.keys(types))
    |> validate_required(Map.keys(types))
    |> validate_format(:source, ~r/@/)
    |> validate_format(:destination, ~r/@/)
    |> validate_source_destination
  end

  defp add_default_amount(changeset) do
    changeset
    |> put_change(:amount, 1_000.00)
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
