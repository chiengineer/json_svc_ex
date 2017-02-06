defmodule KafkaHandlers.Account.RequestCreate do
  @moduledoc """
  KafkaHandlers for account controller
  Publishes to kafka topic using worker defined by `@worker_id`
  a random partition is selected per message

  TODO: include pattern matching for versioned topics
  """

  @worker_id :account_controller_stream
  @topic_model "Account"
  @topic_action "RequestCreate"
  @topic_version "V1"
  @topic Enum.join([@topic_model, @topic_action, @topic_version], ".")
  @partitions [0]

  @spec publish(
    map(),
    %{
      optional(:timestamp) => DateTime.t,
      optional(:request_id) => String.t,
      optional(:handler) => fun()
    }
  ) :: [
    {
      :ok,
      %{
          meta: %{requested_at: String.t, transaction_id: String.t},
          request_body: map()
        }
    }
  ]
  @doc """
    This function is used to publish kafka messages default handler uses
    `KafkaEx`
  """

  def publish(account_payload, timestamp: time), do: publishp(account_payload, format_time(time))
  def publish(account_payload, handler: handler), do: publishp(account_payload, format_time(now()), handler)
  def publish(account_payload, timestamp: time, request_id: id, handler: handler), do: publishp(account_payload, format_time(time), handler, id)
  def publish(account_payload), do: publishp(account_payload, format_time(now()))

  @spec kafka_meta() :: %{
    worker_id: atom(), partitions: Integer.t, topic: String.t
  }
  @doc """
    This function is used to inspect metadata about this defined module as a
    kafka worker process
  """
  def kafka_meta do
    %{worker_id: @worker_id, partitions: @partitions, topic: @topic}
  end

  @spec publishp(map, String.t, fun, String.t) :: {:ok, map}
  defp publishp(payload, timestamp, handler \\ &KafkaEx.produce/4, uuid \\ UUID.uuid4()) do
    {:ok, valid_uuid} = validate_uuid(uuid)
    normalized_payload = payload_normalizer(payload, timestamp, valid_uuid)
    handler.(
      @topic,
      select_random_partition(),
      encode_payload_request(normalized_payload),
      worker_name: @worker_id
    )
    {:ok, normalized_payload}
  end

  @spec validate_uuid(String.t) :: {:ok, String.t}
  defp validate_uuid(uuid) do
    [
      {:uuid, valid_uuid},
      {:binary, _},
      {:type, :default},
      {:version, 4},
      {:variant, :rfc4122}
    ] = UUID.info!(uuid)
    {:ok, valid_uuid}
  end

  @spec select_random_partition() :: integer
  defp select_random_partition do
    Enum.random(@partitions)
  end

  @spec now() :: DateTime
  defp now do
   DateTime.utc_now
  end

  @spec format_time(DateTime.t) :: String.t
  defp format_time(datetime) do
     DateTime.to_iso8601(datetime)
  end

  @spec payload_normalizer(map, String.t, String.t) :: map
  defp payload_normalizer(payload, timestamp, uuid) do
    %{
      meta: %{
        requested_at: timestamp,
        transaction_id: uuid
      },
      request_body: payload
    }
  end

  @spec encode_payload_request(map) :: String.t
  defp encode_payload_request(normalized_payload) do
    Poison.encode!(normalized_payload)
  end
end
