defmodule Kafka.HelpersTest do
  use ExUnit.Case, async: true
  doctest Kafka.Helpers

  test 'now() returns a current datetime' do
    now = DateTime.utc_now()
    result = Kafka.Helpers.now()
    later = DateTime.utc_now()
    assert DateTime.compare(now, result) === :lt
    assert DateTime.compare(result, later) === :lt
  end

  test 'now_string() returns a current iso8601 formatted string' do
    before_t = DateTime.utc_now()
    result_s = Kafka.Helpers.now_string()
    after_t = DateTime.utc_now()
    {:ok, result_t, 0} = DateTime.from_iso8601(result_s)
    assert DateTime.compare(before_t, result_t) === :lt
    assert DateTime.compare(result_t, after_t) === :lt
  end

  test 'encode_payload_request() generates a string from a map' do
    result = Kafka.Helpers.encode_payload_request(%{hello: :world})
    assert result === "{\"hello\":\"world\"}"
  end

  defmodule MockHandler do
    def kafka_meta do
      %{worker_id: :worker_id1, topic: "topic1", partitions: [0]}
    end

    def process_batch(_) do
      send self(), :processing_batch
    end
  end

  test 'fetch_handler_ids(handlers) returns a list of atom identifiers' do
    ids = Kafka.Helpers.fetch_handler_ids([MockHandler])
    assert ids === [:worker_id1]
  end

  defmodule MockWorker do
    def kafka_meta do
      %{worker_id: :worker_id2, topic: "topic2", partitions: [0]}
    end
  end

  test 'fetch_worker_ids collects worker ids from consumer groups' do
    mock_topics = [
      %{
        consume: MockWorker,
        produce: MockHandler,
        handler: &MockHandler.process_batch/1,
        batch_size: 10
      }
    ]

    expected_result = [
      %{
        batch_size: 10,
        handler: &MockHandler.process_batch/1,
        partitions: [0],
        topic: "topic2",
        worker_id: :worker_id2}
    ]
    results = Kafka.Helpers.fetch_worker_ids(mock_topics)
    assert results === expected_result
  end

  test 'start_consumers spawns link to consumers for each' do
    mock_topics = [
      %{
        consume: MockWorker,
        produce: MockHandler,
        handler: &MockHandler.process_batch/1,
        batch_size: 10
      }
    ]

    fetch_messages_handler = fn (_, _, _) ->
      send self(), [%{partitions: [ %{message_set: ["message1"]}]}]
    end

    {status, pids} = Kafka.Helpers.start_consumers(mock_topics, fetch_messages_handler)
    assert status === :ok
    assert length(pids) == length(mock_topics)
  end

end
