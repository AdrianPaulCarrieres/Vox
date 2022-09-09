import Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata [$level] $message\n",
  metadata: [:guild_id, :user_id]

import_config "#{config_env()}.exs"
