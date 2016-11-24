defmodule KafkaHandlers.Account.RequestCreate do
  @moduledoc """
  KafkaHandlers for account controller
  Publishes to kafka topic using worker defined by @worker_id
  a random partition is selected per message
  TODO: include pattern matching for versioned topics
  """

  @worker_id :account_controller_stream
  @topic_model "Account"
  @topic_action "RequestCreate"
  @topic_version "V1"
  @topic Enum.join([@topic_model, @topic_action, @topic_version], ".")
  @partitions [0]

  def publish(account_payload, timestamp: time), do: publishp(account_payload, format_time(time))
  def publish(account_payload, handler: handler), do: publishp(account_payload, format_time(now), handler)
  @spec publish(map, %{timestamp: DateTime}) :: map
  def publish(account_payload, timestamp: time, request_id: id, handler: handler), do: publishp(account_payload, format_time(time), handler, id)
  @spec publish(map) :: map
  def publish(account_payload), do: publishp(account_payload, format_time(now))

  def kafka_meta do
    %{worker_id: @worker_id, partitions: @partitions, topic: @topic}
  end

  defp publishp(payload, timestamp, handler \\ &KafkaEx.produce/4, uuid \\ UUID.uuid4()) do
    normalized_payload = payload_normalizer(payload, timestamp, uuid)
    handler.(
      @topic,
      select_random_partition,
      encode_payload_request(normalized_payload),
      worker_name: @worker_id
    )
    {:ok, normalized_payload}
  end

  defp select_random_partition do
    Enum.random(@partitions)
  end

  defp now do
   DateTime.utc_now
  end

  defp format_time(datetime) do
     DateTime.to_iso8601(datetime)
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
