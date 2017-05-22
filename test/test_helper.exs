defmodule Kafka.MockHandler do
  def handler(topic, partition, json_payload, worker_name: worker_id) do
    send self(), {:payload_sent, [topic, partition, json_payload, worker_name: worker_id]}
    :ok
  end

  def valid_payload do
    %{first_name: "joe", last_name: "bob", email: "joe@bob.com"}
  end

  def valid_request_payload do
    %{
      request_id: "33c5aa7e-3f35-47bc-883b-33ea0ace89f0",
      first_name: "joe", last_name: "bob", email: "joe@bob.com"
    }
  end
end

ExUnit.configure formatters: [JUnitFormatter, ExUnit.CLIFormatter]
ExUnit.configure(exclude: [skip: true])
ExUnit.start()
