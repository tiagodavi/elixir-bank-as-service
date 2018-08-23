use Mix.Config

config :bank_logic, BankLogic.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "${DATABASE_URL}",
  ssl: true,
  pool_size: 1
