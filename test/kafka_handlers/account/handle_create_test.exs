defmodule KafkaHandlers.Account.HandleCreateTest do
  use ExUnit.Case, async: true
  alias KafkaHandlers.Account.HandleCreate, as: HandleCreate

  test "correct topic is received" do
    HandleCreate.create(
      {:ok, Kafka.MockHandler.valid_request_payload},
      &Kafka.MockHandler.handler/4
    )
    assert_received {:payload_sent, [topic, _, _, _]}
    assert topic == "Account.HandleCreate.V1"
    refute_received _
  end

  test "correct partition is received" do
    HandleCreate.create(
      {:ok, Kafka.MockHandler.valid_request_payload},
      &Kafka.MockHandler.handler/4
    )
    assert_received {:payload_sent, [_, 0, _, _]}
    refute_received _
  end

  test "correct payload is received" do
    payload = Kafka.MockHandler.valid_request_payload
    expected_payload = Poison.encode!(%{
      "#{payload.request_id}": [payload]
    })

    HandleCreate.create(
      {:ok, Kafka.MockHandler.valid_request_payload},
      &Kafka.MockHandler.handler/4
    )
    assert_received {:payload_sent, [_, _, payload, _]}
    assert payload == expected_payload
    refute_received _
  end

  test "correct worker name is received" do
    HandleCreate.create(
      {:ok, Kafka.MockHandler.valid_request_payload},
      &Kafka.MockHandler.handler/4
    )
    assert_received {:payload_sent, [_, _, _, worker_name: worker_id]}
    assert worker_id == :account_handle_request_create_stream
    refute_received _
  end
end
