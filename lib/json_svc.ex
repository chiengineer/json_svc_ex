defmodule JsonSvc do
  require Logger
  @moduledoc """
  Base application supervisor that starts the service api router `Router.Base`
  """
  use Application
  alias Router.Base, as: Router
  alias JsonSvc.Supervisor, as: SvcSupervisor
  alias Plug.Adapters.Cowboy, as: Handler
  alias KafkaHandlers.Workers, as: KafkaProducers
  alias KafkaHandlers.Consumers, as: KafkaConsumers


  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(JsonSvc.Sockets.Endpoint, []),
      worker(__MODULE__, [], function: :start_server),
      worker(KafkaConsumers, []),
      supervisor(Phoenix.PubSub.PG2, [JsonSvc.Channels.Room, []])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    KafkaProducers.create_workers
    opts = [strategy: :one_for_one, name: SvcSupervisor]
    Supervisor.start_link(children, opts)
  end

  def start_server do
    Logger.info "Starting http router"
    {:ok, _} = Handler.http Router, [], dispatch: dispatch
  end

  # def start_socket_server do
  #   Logger.info "Starting socket server"
  #   {:ok, _} =
  # end

  defp dispatch do
    [
      {:_, [
        {"/ws", JsonSvc.Sockets.Endpoint, []},
        {:_, Plug.Adapters.Cowboy.Handler, {Router, []}}
      ]}
    ]
  end

end
