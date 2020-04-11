use Mix.Config

config :backend, Backend.Repo,
  ssl: true,
  url: System.get_env("DATABASE_URL"),
  pool_size: 10

config :backend, BackendWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: System.get_env("URL"), port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Set Telynx variables
config :backend, :status_url, "https://#{System.get_env("URL")}/telnyx/status"
config :backend, :telnyx_api_key, System.get_env("TELNYX_API_KEY")

# Do not print debug messages in production
config :logger, level: :info
