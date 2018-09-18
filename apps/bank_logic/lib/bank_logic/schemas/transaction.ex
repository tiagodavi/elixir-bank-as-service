defmodule BankLogic.Schemas.Transaction do
  @moduledoc """
  Transaction Schema to handle validations
  """

  @operations %{
    transfer: 1,
    cash_out: 2
  }

  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field(:source_id, :id)
    field(:destination_id, :id)
    field(:operation, :integer)
    field(:amount, Money.Ecto.Type)
    timestamps()
  end

  def report_changeset(attrs) do
    data = %{}
    types = %{start_date: :date, end_date: :date}

    {data, types}
    |> cast(attrs, Map.keys(types))
    |> validate_required(Map.keys(types))
    |> validate_dates
  end

  defp validate_dates(changeset) do
    start_date = get_change(changeset, :start_date)
    end_date = get_change(changeset, :end_date)

    if start_date >= end_date do
      add_error(changeset, :dates, "start_date is greater or equal than end_date")
    else
      changeset
    end
  end

  def operations, do: @operations
end
