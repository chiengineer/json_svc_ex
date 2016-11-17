require KafkaEx

defmodule KafkaHandlers.Workers do
  @moduledoc """
  Kafka Workers - create workers with atoms for handling different controller
  streams
  """
  @workers [
    :about_controller_stream
  ]

  def create_workers do
    Enum.map(
      @workers,
      fn(w) -> KafkaEx.create_worker(w) end
    )
  end
end
