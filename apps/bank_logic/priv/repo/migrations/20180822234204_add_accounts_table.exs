defmodule BankLogic.Repo.Migrations.AddAccountsTable do
  use Ecto.Migration

  def change do
    create table("accounts") do
      add :number,  :string
      add :amount, :integer
      timestamps()
    end
    create unique_index(:accounts, [:number])
  end
end
