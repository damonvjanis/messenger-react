use Mix.Config

# Defines the repo
config :backend,
  ecto_repos: [Backend.Repo]

# Configures the endpoint
config :backend, BackendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bCi0RhThxhoMdIA53yxtt/1VSCAV+QqKMc6GmagMz69UaF/BDoL29smlRSUfuwWn",
  render_errors: [view: BackendWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Backend.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures the Repo
config :backend, Backend.Repo, migration_timestamps: [type: :naive_datetime_usec]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
