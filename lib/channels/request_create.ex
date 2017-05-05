require Logger

defmodule JsonSvc.Channels.RequestCreate do
  use Phoenix.Channel

  def join("request_create:"<> transaction_id, _, socket) do
    Logger.info "user joining Request Create in #{transaction_id}"
    :ok = Phoenix.PubSub.subscribe(JsonSvc.Channels.RequestCreate, "request_create:#{transaction_id}")
    :ok = looping_publish_events_to_channelp(transaction_id)
    {:ok, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket, %{channel: channel}) do
    Phoenix.PubSub.broadcast(JsonSvc.Channels.RequestCreate, channel, body)
    {:noreply, socket}
  end

  def broadcast_to_channel(message, channel) do
    :ok
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  defp looping_publish_events_to_channelp(transaction_id) do
    {:ok, pid} = GenServer.start_link(KafkaHandlers.ResultCreate, [:"#{transaction_id}"])
    require IEx; IEx.pry
    GenServer.cast(pid, {:fetch_events, transaction_id}, %{handler: &JsonSvc.Channels.RequestCreate.broadcast_to_channel/2})
    :ok
  end

end

defmodule KafkaHandlers.ResultCreate do
  use GenServer

  alias Kafka.Helpers, as: Helper

  # @topics [
  #   %{
  #     consume: KafkaHandlers.Account.Accounts,
  #     handler: &KafkaHandlers.Account.HandleCreate.process_batch/2,
  #     batch_size: 10
  #     options: %{}
  #   }
  # ]

  def handle_cast({:fetch_events, transaction_id, state}) do
    require IEx; IEx.pry
  end
end
