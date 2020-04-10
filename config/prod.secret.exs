use Mix.Config

config :backend, BackendWeb.Endpoint,
  http: [:inet6, port: 4000],
  secret_key_base: System.get_env("SECRET_KEY_BASE")
