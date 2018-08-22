use Mix.Config

config :bank_logic, BankLogic.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "ecto://postgres:postgres@localhost/bank_logic_dev"
