defmodule KafkaHandlers.Account.RequestCreate do
  @moduledoc """
  KafkaHandlers for account controller
  Publishes to kafka topic using worker defined by @worker_id
  a random partition is selected per message
  TODO: include pattern matching for versioned topics
  """

  @worker_id :account_controller_stream
  @partitions [0]

  def publish(account_payload, timestamp: time), do: publishp(account_payload, DateTime.to_iso8601(time))
  def publish(account_payload), do: publishp(account_payload, DateTime.to_iso8601(DateTime.utc_now))

  def kafka_meta do
    %{worker_id: @worker_id, partitions: @partitions}
  end

  defp publishp(payload, timestamp) do
    uuid = UUID.uuid4()
    normalized_payload = payload_normalizer(payload, timestamp, uuid)
    KafkaEx.produce(
      "Account.RequestCreate.V1",
      select_random_partition,
      encode_payload_request(normalized_payload),
      worker_name: @worker_id
    )
    {:ok, normalized_payload}
  end

  defp select_random_partition do
    Enum.random(@partitions)
  end

  defp payload_normalizer(payload, timestamp, uuid) do
    %{
      meta: %{
        requested_at: timestamp,
        transaction_id: uuid
      },
      request_body: %{
        first_name: payload.first_name,
        last_name: payload.last_name,
        email: payload.email
      }
    }
  end

  defp encode_payload_request(normalized_payload) do
    Poison.encode!(normalized_payload)
  end
end
