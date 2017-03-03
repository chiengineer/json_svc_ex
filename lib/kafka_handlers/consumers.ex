require KafkaEx
require Logger

defmodule KafkaHandlers.Consumers do
  use GenServer
  @moduledoc """
  Kafka Workers - create workers with atoms for handling different controller
  streams
  `@workers` list of worker modules that contain interface kafka_meta
  """

  alias Kafka.Helpers, as: Helper

  @topics [
    %{
      consume: KafkaHandlers.Account.RequestCreate,
      produce: KafkaHandlers.Account.HandleCreate,
      handler: &KafkaHandlers.Account.HandleCreate.process_batch/1,
      batch_size: 10
    }
  ]


  def start_link do
    GenServer.start_link(__MODULE__, [], name: :kafka_handlers_consumers)
  end

  def init(state) do
    Helper.start_consumers(@topics)
    {:ok, state}
  end

  def handle_info(:work, state) do
    {:noreply, state}
  end
end
