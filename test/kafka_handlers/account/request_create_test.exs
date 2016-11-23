defmodule MockHandler do
  def handler do
    fn (topic, partition, json_payload, worker_name: worker_id) ->
      send self(), {:payload_sent, [topic, partition, json_payload, worker_name: worker_id]}
    end
  end

  def valid_payload do
    %{first_name: "joe", last_name: "bob", email: "joe@bob.com"}
  end
end

defmodule KafkaHandlers.Account.RequestCreateTest do
  use ExUnit.Case, async: true
  alias KafkaHandlers.Account.RequestCreate, as: RequestCreate

  test "correct topic is received" do
    RequestCreate.publish(
      MockHandler.valid_payload,
      handler: MockHandler.handler
    )
    assert_received {:payload_sent, [topic, _, _, _]}
    assert topic == "Account.RequestCreate.V1"
    refute_received _
  end

  test "correct partition is received" do
    RequestCreate.publish(
      MockHandler.valid_payload,
      handler: MockHandler.handler
    )
    assert_received {:payload_sent, [_, 0, _, _]}
    refute_received _
  end

  test "correct payload is received" do
    timestamp = DateTime.utc_now
    uuid = UUID.uuid4()
    expected_payload = Poison.encode!(%{
      meta: %{
        requested_at: DateTime.to_iso8601(timestamp),
        transaction_id: uuid
      },
      request_body: MockHandler.valid_payload
    })

    RequestCreate.publish(
      MockHandler.valid_payload,
      timestamp: timestamp,
      request_id: uuid,
      handler: MockHandler.handler
    )
    assert_received {:payload_sent, [_, _, payload, _]}
    assert payload == expected_payload
    refute_received _
  end

  test "correct worker name is received" do
    RequestCreate.publish(
      MockHandler.valid_payload,
      handler: MockHandler.handler
    )
    assert_received {:payload_sent, [_, _, _, worker_name: worker_id]}
    assert worker_id == :account_controller_stream
    refute_received _
  end

  @tag :skip
  test "circle build with live kafka generates workers without stubs"
end
