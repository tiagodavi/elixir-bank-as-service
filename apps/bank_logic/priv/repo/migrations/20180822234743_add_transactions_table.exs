defmodule BankLogic.Repo.Migrations.AddTransactionsTable do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :operation, :integer
      add :amount, :integer
      add :source_id, references(:accounts, on_delete: :delete_all), null: false
      add :destination_id, references(:accounts, on_delete: :delete_all), null: true

      timestamps()
    end
  end
end
