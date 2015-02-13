# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :elixir_rails_websockets, ElixirRailsWebsockets.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "xupzy620h2X9aSqSH9Ixhnvv9f6rut1+EQIrvH2sMa18ETYqEP+Gw1QjdUv5WVlU",
  debug_errors: false,
  pubsub: [adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
