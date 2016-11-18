use Mix.Config

config :honeybadger,
  api_key: "yourkeyhere",
  environment_name: :dev

config :logger,
  backends: [:console],
  compile_time_purge_level: :info

#update this with your relevant host details or use dev.overrides.exs

config :kafka_ex,
  brokers: [{"192.168.99.100", 9092}],
  consumer_group: "kafka_ex",
  disable_default_worker: false,
  sync_timeout: 3000,
  max_restarts: 10,
  max_seconds: 60,
  kafka_version: "0.9.0"
