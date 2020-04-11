use Mix.Config

# Configure your database
config :backend, Backend.Repo,
  username: "postgres",
  password: "postgres",
  database: "backend_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Disable cache and enable debugging and code reloading
config :backend, BackendWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set base app url
config :backend, :url, "localhost:4000"

# Set Telynx variables
config :backend, :telnyx_number, "+16673083511"
config :backend, :status_url, "https://35c9c125.ngrok.io/telnyx/status"

# Set email for notifications
config :backend, :notification_email, "damonvjanis@gmail.com"

# Set login code
config :backend, :login_code, "messenger"
