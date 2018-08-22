# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bank_api,
  namespace: BankApi

# Configures the endpoint
config :bank_api, BankApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sK+DDZhkMYUL7RfzB14h9gLCYWa2mZ2H82TPieNR58sw3ieA2q4JKUfkvw/67l4D",
  render_errors: [view: BankApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BankApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
