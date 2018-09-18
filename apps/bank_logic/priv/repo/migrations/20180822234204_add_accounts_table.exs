defmodule BankLogic.Repo.Migrations.AddAccountsTable do
  use Ecto.Migration

  def change do
    create table("accounts") do
      add :key,  :string
      add :amount, :integer
      timestamps()
    end
    create unique_index(:accounts, [:key])
  end
end
