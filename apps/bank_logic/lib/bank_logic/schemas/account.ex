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

  defp add_default_amount(changeset) do
    changeset
    |> put_change(:amount, 1_000.00)
  end
end
