use Mix.Config

config :bank_logic, BankLogic.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  url: "ecto://postgres:postgres@localhost/bank_logic_test"
