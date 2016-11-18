require KafkaEx

defmodule KafkaHandlers.Workers do
  @moduledoc """
  Kafka Workers - create workers with atoms for handling different controller
  streams
  @workers list of worker modules that contain interface kafka_meta
  kafka_meta - %{worker_id: identifier for worker to use}
  """
  @workers [KafkaHandlers.Account.RequestCreate]

  def create_workers do
    Enum.map(
      fetch_worker_ids,
      fn(w) -> KafkaEx.create_worker(w) end
    )
  end

  defp fetch_worker_ids do
     ids = Enum.map(
      @workers,
      fn(w) -> fetch_worker_id(w) end
     )
     Enum.uniq(ids)
  end

  defp fetch_worker_id(worker) do
     worker.kafka_meta[:worker_id]
  end
end
