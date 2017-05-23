require Logger

defmodule KafkaHandlers.Account.ResultCreate do
  @moduledoc """
  Account.ResultCreate is a just in time kafka consumer to watch results from
  an account request create to be delivered back to any given consumer
  """
  use GenServer

  alias Kafka.Helpers, as: Helper
  alias KafkaHandlers.Account.HandleCreate, as: Consumer

  def handle_cast({:fetch_events, options}, state) do
    Helper.start_consumers([build_consumer(options)])
    {:noreply, state}
  end

  def build_consumer(options) do
    %{
      consume: Consumer,
      handler: &process_batch/2,
      batch_size: 10,
      options: options
    }
  end

  def process_batch(message_batch, %{id: id, handler: handler}) do
    Logger.info("Processing #{inspect(length(message_batch))} messages")
    :ok = message_batch
      |> Flow.from_enumerable()
      |> Flow.map(&Poison.decode!/1)
      |> Flow.filter(fn(message) ->
          message[id] != nil
        end)
      |> Flow.map(&Poison.encode!/1)
      |> Flow.map(&handler.(&1, id))
      |> Flow.run()
    :batch_processed
  end
end
