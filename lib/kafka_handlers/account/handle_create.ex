defmodule KafkaHandlers.Account.HandleCreate do
  require Logger
  @moduledoc """
  KafkaHandlers for messages to `RequestCreate`
  Publishes to kafka topic using worker defined by `@worker_id`
  a random partition is selected per message

  TODO: include pattern matching for versioned topics
  """

  alias KafkaHandlers.Account.Accounts, as: AccountHandler

  @worker_id :account_handle_request_create_stream
  @topic_model "Account"
  @topic_action "HandleCreate"
  @topic_version "V1"
  @topic Enum.join([@topic_model, @topic_action, @topic_version], ".")
  @partitions [0]

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

  def process_batch(message_batch) do
    Logger.info("Processing #{inspect(length(message_batch))} messages")
    message_batch
      |> Flow.from_enumerable()
      |> Flow.map(&Poison.decode!/1)
      |> Flow.map(&AccountHandler.normalize_body/1)
      |> Flow.map(&AccountHandler.create/1)
      |> Flow.run()
    :created
  end



end
