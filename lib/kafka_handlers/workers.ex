require KafkaEx
require Logger

defmodule KafkaHandlers.Workers do
  @moduledoc """
  Kafka Workers - create workers with atoms for handling different controller
  streams
  `@workers` list of worker modules that contain interface kafka_meta
  """
  alias Kafka.Helpers, as: Helper

  @workers [
    KafkaHandlers.Account.RequestCreate,
    KafkaHandlers.Account.HandleCreate
  ]

  @doc """
    This function creates workers injected from the array `@workers` workers
    _must_ impliment `.kafka_meta[:worker_id]`
  """
  @spec create_workers(function) :: [pid]
  def create_workers(handler \\ &KafkaEx.create_worker/2) do
    handlers = Helper.fetch_handler_ids(@workers)
    handlers
      |> Enum.map(fn(w) ->
        Logger.info("Starting Producer Worker to #{w}")
        handler.(w, [consumer_group: "#{w}"]) end)
  end
end
