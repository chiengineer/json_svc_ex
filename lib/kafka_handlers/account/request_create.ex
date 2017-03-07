defmodule KafkaHandlers.Account.RequestCreate do
  @moduledoc """
  KafkaHandlers for account controller
  Publishes to kafka topic using worker defined by `@worker_id`
  a random partition is selected per message

  TODO: include pattern matching for versioned topics
  """
  alias Kafka.Helpers, as: Helper

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

  def publish(account_payload, timestamp: time) do
    publishp(account_payload, Helper.format_time(time))
  end

  def publish(account_payload, handler: handler) do
    publishp(account_payload, Helper.now_string(), handler)
  end

  def publish(payload, timestamp: time, request_id: id, handler: handler) do
    publishp(payload, Helper.format_time(time), handler, id)
  end
  def publish(account_payload) do
    publishp(account_payload, Helper.now_string())
  end

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
    {:ok, valid_uuid} = Helper.validate_uuid(uuid)
    normalized_payload =
      Helper.payload_normalizer(payload, timestamp, valid_uuid)
    :ok = handler.(
      @topic,
      Helper.select_random_partition(@partitions),
      Helper.encode_payload_request(normalized_payload),
      worker_name: @worker_id
    )
    {:ok, normalized_payload}
  end
end
