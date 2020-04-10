use Mix.Config

config :backend, Backend.Repo,
  ssl: true,
  url: System.get_env("DATABASE_URL"),
  pool_size: 10

config :backend, BackendWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: System.get_env("URL"), port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]]

# Do not print debug messages in production
config :logger, level: :info

import_config "prod.secret.exs"
