defmodule BankLogic.Schemas.Transaction do
  @moduledoc """
  Transaction Schema to handle validations
  """

  @operations %{
    send_money: 1,
    cash_out: 2
  }

  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field(:source_id, :id)
    field(:destination_id, :id)
    field(:operation, :integer)
    field(:amount, :float)
    timestamps()
  end

  def operations, do: @operations
end
