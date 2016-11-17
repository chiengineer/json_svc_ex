defmodule KafkaHandlers.Account.RequestCreate do
  @moduledoc """
  KafkaHandlers for account controller
  Publishes to kafka topic using worker defined by @worker_id
  a random partition is selected per message
  TODO: include pattern matching for versioned topics
  TODO: include transaction ID in payload
  TODO: include timestamp in payload
  """

  @worker_id :account_controller_stream
  @partitions [0]

  def publish(account_payload) do
    KafkaEx.produce(
      "Account.RequestCreate.V1",
      select_random_partition,
      encode_payload_request(account_payload),
      worker_name: @worker_id
    )
  end

  def kafka_meta do
    %{worker_id: @worker_id, partitions: @partitions}
  end

  defp select_random_partition do
    Enum.random(@partitions)
  end

  defp encode_payload_request(payload) do
    Poison.encode!(payload)
  end
end
