defmodule Kafka.Helpers do
  require Logger

  @moduledoc """
  Kafka.Helpers provides helper functions to simplify producing, consuming and
  interacting with kafka topics
  """

  @doc """
  validates a string as a uuid
  ## Examples
  ```
  iex> Kafka.Helpers.validate_uuid("33c5aa7e-3f35-47bc-883b-33ea0ace89f0")
  {:ok, "33c5aa7e-3f35-47bc-883b-33ea0ace89f0"}

  iex> Kafka.Helpers.validate_uuid("some_string")
  {:error, :invalid_uuid}

  ```
  """
  @spec validate_uuid(String.t) :: {:ok, String.t} | {:error, :invalid_uuid}
  def validate_uuid(uuid) do
    [
      {:uuid, valid_uuid},
      {:binary, _},
      {:type, :default},
      {:version, 4},
      {:variant, :rfc4122}
    ] = UUID.info!(uuid)
    {:ok, valid_uuid}
  rescue
    _ -> {:error, :invalid_uuid}
  end

  @doc """
  generate a utc standardized timestamp
  """
  @spec now() :: DateTime.t
  def now do
   DateTime.utc_now
  end

  @doc """
  formate a timestamp to a iso formated datetime

  Examples
  ```
  iex> timestamp = "2017-03-19T02:48:15.814147Z"
  iex> {:ok, time, _} = DateTime.from_iso8601(timestamp)
  iex> Kafka.Helpers.format_time(time)
  "2017-03-19T02:48:15.814147Z"
  ```
  """
  @spec format_time(DateTime.t) :: String.t
  def format_time(datetime) do
     DateTime.to_iso8601(datetime)
  end

  @doc """
  genreates an iso8601 now timestamp
  """
  def now_string() do
    format_time(now())
  end

  @doc """
  creates a json payload from an incoming map
  """
  @spec encode_payload_request(map) :: String.t
  def encode_payload_request(normalized_payload) do
    Poison.encode!(normalized_payload)
  end

  @doc """
  selects a random value from a set of partions

  Examples
  ```
  iex> partitions = [1]
  iex> Kafka.Helpers.select_random_partition(partitions)
  1
  ```
  """
  @spec select_random_partition([integer]) :: integer
  def select_random_partition(partitions) do
    Enum.random(partitions)
  end

  @doc """
  Normalizes an outgoing payload
  Examples
  ```
  iex> payload = %{hello: :world}
  iex> time = "2017-03-19T02:48:15.814147Z"
  iex> uuid = "33c5aa7e-3f35-47bc-883b-33ea0ace89f0"
  iex> Kafka.Helpers.payload_normalizer(payload, time, uuid)
  %{meta: %{
    requested_at: "2017-03-19T02:48:15.814147Z",
    transaction_id: "33c5aa7e-3f35-47bc-883b-33ea0ace89f0"},
  request_body: %{hello: :world}}
  ```
  """
  @spec payload_normalizer(map, String.t, String.t) :: map
  def payload_normalizer(payload, timestamp, uuid) do
    %{
      meta: %{
        requested_at: timestamp,
        transaction_id: uuid
      },
      request_body: payload
    }
  end

  @doc """
  fetches uniq worker ids from a collection of kafka worker module names via
  kafka_meta/0
  """
  @spec fetch_handler_ids([reference]) :: [atom]
  def fetch_handler_ids(handlers) do
    handlers
      |> Enum.map(&fetch_handler_id/1)
      |> Enum.uniq
  end

  @doc """
  collects normalized payloads of uniq consumers, handlers and expected batch
  sizes
  """
  @spec fetch_worker_ids([reference]) :: atom | [atom]
  def fetch_worker_ids(topics) do
    topics
      |> Enum.map(
        fn(w) -> fetch_worker_payloads(
          w[:consume],
          w[:handler],
          w[:batch_size],
          w[:options]
        ) end)
      |> Enum.uniq()
  end

  @doc """
  starts a collection of consumer workers defaulting to KafkaEx.fetch/3 for
  the message handler
  """
  @spec start_consumers([String.t], fun) :: {:ok, [pid]}
  def start_consumers(topics, handler \\ &KafkaEx.fetch/3) do
    worker_ids = fetch_worker_ids(topics)
    pids = worker_ids
      |> Enum.map(fn(w) ->
        Logger.info("Starting consumer for #{w.topic}")
        get_linksp(w[:partitions], w, handler)
      end)
    {:ok, pids}
  end

  @spec fetch_handler_id(module) :: atom
  defp fetch_handler_id(worker) do
     worker.kafka_meta[:worker_id]
  end

  @spec fetch_worker_payloads(module, fun, integer, map()) ::
    %{
      topic: String.t, partitions: list(any), handler: fun,
      batch_size: integer, worker_id: atom, options: map()
    }
  defp fetch_worker_payloads(consumer, handler, batch_size, opts) do
    %{
      topic: consumer.kafka_meta[:topic],
      partitions: consumer.kafka_meta[:partitions],
      handler: handler,
      batch_size: batch_size,
      worker_id: consumer.kafka_meta[:worker_id],
      options: opts
    }
  end

  @doc """
  Reindexes payload by `request_id`
  Examples
  ```
  iex> request_id = "33c5aa7e-3f35-47bc-883b-33ea0ace89f0"
  iex> payload = %{request_id: request_id, other_key: "foo"}
  iex> Kafka.Helpers.index_payload_by_request_id(payload)
  %{
    "33c5aa7e-3f35-47bc-883b-33ea0ace89f0": [
      %{request_id: "33c5aa7e-3f35-47bc-883b-33ea0ace89f0",
      other_key: "foo"}
    ]
  }
  ```
  """
  def index_payload_by_request_id(payload) do
    {:ok, request_id} = extract_request_idp(payload)
    {:ok, valid_uuid} = validate_uuid(request_id)
    %{
      "#{valid_uuid}": [payload]
    }
  end

  defp extract_request_idp(payload) do
    case payload do
      %{request_id: id} -> {:ok, id}
      _anything         -> {:error, :malfomred_request}
    end
  end

  def looping_fetch_messages(partition, w, handler) do
    worker_msgs = handler.(w[:topic], partition, [worker_name: w[:worker_id]])
    handle_messagesp(worker_msgs, w)
    looping_fetch_messages(partition, w, handler)
  end

  defp handle_messagesp(:topic_not_found, _), do: :no_topic

  defp handle_messagesp(worker_msgs, w) do
    messages = worker_msgs
      |> Enum.flat_map(fn(p) -> p.partitions end)
      |> Enum.flat_map(fn(p) -> p.message_set end)
    process_batchp(messages, w[:handler], w[:batch_size], w[:options])
  end

  defp ensure_valid_request(partition, w, handler) do
    response = handler.(w[:topic], partition, [worker_name: w[:worker_id]])
    groups = response
      |> Enum.flat_map(fn(response) ->
        response.partitions
          |> Enum.map(fn(p) ->
            Map.put(p, :topic, response.topic)
          end)
      end)
      |> Enum.group_by(fn(r) -> r.error_code end)

    full_groups = %{
      offset_out_of_range: [],
      no_error: [],
      invalid_message: []
    }

    %{
      offset_out_of_range: requests_to_reset,
      no_error: ok_requests,
      invalid_message: requests_to_raise
    } = Map.merge(full_groups, groups)
    ok_requests
  end

  defp get_linksp(partitions, worker_id, handler) do
    partitions
      |> Enum.map(fn(partition) ->
        Logger.info("Spawning Link for #{partition}")
        spawn_link(fn ->
          looping_fetch_messages(partition, worker_id, handler)
        end)
      end)
  end

  defp process_batchp([], _, _, _) do
    :timer.sleep(1000)
    :empty_messages
  end

  defp process_batchp(kafka_messages, handler, batch_size, options) do
    messages = kafka_messages
      |> Flow.from_enumerable(max_demand: batch_size)
      |> Flow.map(fn(m) -> m.value end)
      |> Enum.to_list
    handler.(messages, options)
    :processed_batch
  end

end
