defmodule BankLogic.Repo.Migrations.AddAccountsTable do
  use Ecto.Migration

  def change do
    create table("accounts") do
      add :email,  :string
      add :amount, :float
      timestamps()
    end
    create unique_index(:accounts, [:email])
  end
end
