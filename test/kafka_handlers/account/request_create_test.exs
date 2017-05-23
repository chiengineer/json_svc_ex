defmodule KafkaHandlers.Account.RequestCreateTest do
  use ExUnit.Case, async: true
  alias KafkaHandlers.Account.RequestCreate, as: RequestCreate

  test "correct topic is received" do
    RequestCreate.publish(
      Kafka.MockHandler.valid_payload,
      handler: &Kafka.MockHandler.handler/4
    )
    assert_received {:payload_sent, [topic, _, _, _]}
    assert topic == "Account.RequestCreate.V1"
    refute_received _
  end

  test "correct partition is received" do
    RequestCreate.publish(
      Kafka.MockHandler.valid_payload,
      handler: &Kafka.MockHandler.handler/4
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
      request_body: Kafka.MockHandler.valid_payload
    })

    RequestCreate.publish(
      Kafka.MockHandler.valid_payload,
      timestamp: timestamp,
      request_id: uuid,
      handler: &Kafka.MockHandler.handler/4
    )
    assert_received {:payload_sent, [_, _, payload, _]}
    assert payload == expected_payload
    refute_received _
  end

  test "correct worker name is received" do
    RequestCreate.publish(
      Kafka.MockHandler.valid_payload,
      handler: &Kafka.MockHandler.handler/4
    )
    assert_received {:payload_sent, [_, _, _, worker_name: worker_id]}
    assert worker_id == :account_controller_stream
    refute_received _
  end

  @tag :skip
  test "circle build with live kafka generates workers without stubs"

  test "`create` publishes a payload event indexed by the request_id" do

  end
end
