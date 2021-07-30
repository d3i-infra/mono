use Mix.Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1
# Configure your database
config :core, Core.Repo,
  username: "postgres",
  password: "postgres",
  database: "link_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

host = "0812596b65e7.ngrok.io"

config :core, CoreWeb.Endpoint,
  url: [host: host],
  force_ssl: false,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads)/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/core_web/(live|views)/.*(ex)$",
      ~r"lib/core_web/templates/.*(eex)$",
      ~r"bundles/*/.*(ex)$",
      ~r"bundles/*/templates/.*(eex)$"
    ]
  ],
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :core, Core.ImageCatalog.Unsplash,
  access_key: System.get_env("UNSPLASH_ACCESS_KEY"),
  app_name: System.get_env("UNSPLASH_APP_NAME")

config :exsync,
  addition_dirs: ["../../frameworks"]

config :web_push_encryption, :vapid_details,
  subject: "mailto:administrator@example.com",
  public_key:
    "BLddMfMPHE67WZkYxELLBedpRNvJMj7xTbn8ZsObC_0c1-p-AsHl7ndhoty2YURTgCR0XMPm6Mf-74FnwH32fhw",
  private_key: "yWo9lKKkdbN1IGQH8aUlk3u_Shemyh8CmtDnJoNdhBk"

config :core, :apns_backend, backend: Core.APNS.LoggingBackend

config :core, :static_path, "/Users/emiel"

config :core, Core.SurfConext,
  redirect_uri: "https://#{host}/surfconext/auth",
  site: "https://connect.test.surfconext.nl",
  client_id: "bd7a871c5098.ngrok.io",
  client_secret: "VEeE2YFqRbH0JXoTUWMu"