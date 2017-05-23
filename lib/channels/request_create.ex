require Logger

defmodule JsonSvc.Channels.RequestCreate do
  @moduledoc """
  RequestCreate Channel is used to watch for updates against Account Create
  Requests. It is a pubsub for a specific request ID from a given user
  """
  use Phoenix.Channel

  alias Phoenix.PubSub, as: PubSub
  alias JsonSvc.Channels.RequestCreate, as: Self
  alias KafkaHandlers.Account.ResultCreate, as: Listener

  def join(token, _auth_message, socket) do
    Logger.info "user joining RequestCreate observer"
    channel = "request_create:" <> token
    looping_publish_events_to_channelp(token)
    :ok = PubSub.subscribe(Self, channel)
    PubSub.broadcast(Self, channel, "Fetching Events")

    {:ok, socket}
  end

  def leave(_token, _reason, _socket) do
    :ok
  end

  def handle_in(_, _, socket, _) do
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  def broadcast_to_channel(message, channel) do
    PubSub.broadcast(
      Self,
      "request_create:" <> channel,
      message)
  end

  defp looping_publish_events_to_channelp(transaction_id) do
    {:ok, pid} = GenServer.start_link(
      Listener,
      [], id: :"#{transaction_id}")
    GenServer.cast(pid, {:fetch_events,
      %{id: transaction_id, handler: &broadcast_to_channel/2}
    })
    :ok
  end
end
