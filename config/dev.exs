use Mix.Config

config :honeybadger,
  api_key: "yourkeyhere",
  environment_name: :dev

config :logger,
  backends: [:console],
  compile_time_purge_level: :info
