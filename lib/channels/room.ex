require Logger

defmodule JsonSvc.Channels.Room do
  @moduledoc """
  Room Channel is a general purpose pubsub for events to be used as an example
  """
  use Phoenix.Channel
  alias Phoenix.PubSub, as: PubSub
  alias JsonSvc.Channels.Room, as: Self

  def join("room:lobby", auth_message, socket) do
    Logger.info "user joining Lobby"
    :ok = PubSub.subscribe(Self, "room:lobby")
    {:ok, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket, %{channel: channel}) do
    PubSub.broadcast(Self, channel, body)
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

end
