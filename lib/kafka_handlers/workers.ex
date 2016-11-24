require KafkaEx

defmodule KafkaHandlers.Workers do
  @moduledoc """
  Kafka Workers - create workers with atoms for handling different controller
  streams
  `@workers` list of worker modules that contain interface kafka_meta
  """
  @workers [KafkaHandlers.Account.RequestCreate]

  @doc """
    This function creates workers injected from the array `@workers` workers
    _must_ impliment `.kafka_meta[:worker_id]`
  """
  @spec create_workers() :: [pid]
  def create_workers(handler \\ &KafkaEx.create_worker/1) do
    Enum.map(
      fetch_worker_ids,
      fn(w) -> handler.(w) end
    )
  end

  @spec fetch_worker_ids() :: [atom]
  defp fetch_worker_ids do
     ids = Enum.map(
      @workers,
      fn(w) -> fetch_worker_id(w) end
     )
     Enum.uniq(ids)
  end

  @spec fetch_worker_id(module) :: atom
  defp fetch_worker_id(worker) do
     worker.kafka_meta[:worker_id]
  end
end
