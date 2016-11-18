defmodule JsonSvc do
  require Logger
  @moduledoc """
  Base application supervisor that starts the service api router `Router.Base`
  """
  use Application
  alias Router.Base, as: Router
  alias JsonSvc.Supervisor, as: SvcSupervisor
  alias Plug.Adapters.Cowboy, as: Handler
  alias KafkaHandlers.Workers, as: Kafka

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(__MODULE__, [], function: :start_server)
    ]

    Kafka.create_workers

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SvcSupervisor]
    Supervisor.start_link(children, opts)
  end

  def start_server do
    Logger.info "Starting http router"
    {:ok, _} = Handler.http Router, []
  end

end
