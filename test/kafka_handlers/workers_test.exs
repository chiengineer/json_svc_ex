defmodule KafkaHandlers.WorkersTest do
  use ExUnit.Case, async: true
  alias KafkaHandlers.Workers, as: Workers

  test "all kafka workers are created" do
    worker_handler = fn worker_id ->
      send self(), worker_id
    end
    Workers.create_workers(worker_handler)
    assert_received :account_controller_stream
    refute_received _
  end

  @tag :skip
  test "circle build with live kafka generates workers without stubs"
end
