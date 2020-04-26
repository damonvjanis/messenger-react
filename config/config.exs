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

# Set Cloudinary variables
config :backend, :cloudinary_url, System.get_env("CLOUDINARY_URL")

# Set Mailgun variables
config :backend, :mailgun_domain, System.get_env("MAILGUN_DOMAIN")
config :backend, :mailgun_api_key, System.get_env("MAILGUN_API_KEY")

# Set Telynx variables
config :backend, :telnyx_number, System.get_env("TELNYX_NUMBER")
config :backend, :status_url, "https://#{System.get_env("APP_NAME")}.herokuapp.com/telnyx/status"
config :backend, :telnyx_api_key, System.get_env("TELNYX_API_KEY") || ""

# Set base app url
config :backend, :url, "#{System.get_env("APP_NAME")}.herokuapp.com"

# Set email for notifications
config :backend, :notification_email, System.get_env("NOTIFICATION_EMAIL")

# Set login code
config :backend, :login_code, System.get_env("LOGIN_CODE")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
