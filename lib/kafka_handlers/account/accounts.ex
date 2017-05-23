defmodule KafkaHandlers.Account.Accounts do
  @moduledoc """
  KafkaHandlers for messages to `RequestCreate`
  Publishes to kafka topic using worker defined by `@worker_id`
  a random partition is selected per message

  TODO: include pattern matching for versioned topics
  """
  alias Kafka.Helpers, as: Helper

  @worker_id :account_handle_request_create_stream
  @topic_model "Account"
  @topic_action "Accounts"
  @topic_version "V1"
  @topic Enum.join([@topic_model, @topic_action, @topic_version], ".")
  @partitions [0]

  def kafka_meta do
    %{worker_id: @worker_id, partitions: @partitions, topic: @topic}
  end

  def create(payload, handler \\ &KafkaEx.produce/4) do
    normalized_payload = Helper.encode_payload_request(payload)
    key = Helper.select_random_partition(@partitions)
    :ok = handler.(@topic, key, normalized_payload, worker_name: @worker_id)
    {:ok, payload}
  end

  def normalize_body(payload) do
    %{
      "request_body" => %{
        "last_name" => last_name,
        "first_name" => first_name,
        "email" => email
      },
      "meta" => %{
        "transaction_id" => id,
        "requested_at" => requested_at
      }
    } = payload

    {:ok, uuid} = Helper.validate_uuid(id)

    %{
      first_name: first_name,
      last_name: last_name,
      email: email,
      request_id: uuid,
      requested_at: requested_at,
      created_at: Helper.now_string()
    }
  end
end
