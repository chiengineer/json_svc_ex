require Logger

defmodule JsonSvc.Channels.Room do
  use Phoenix.Channel

  def join("room:lobby", auth_message, socket) do
    Logger.info "user joining Lobby"
    :ok = Phoenix.PubSub.subscribe(JsonSvc.Channels.Room, "room:lobby")
    {:ok, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket, %{channel: channel}) do
    Phoenix.PubSub.broadcast(JsonSvc.Channels.Room, channel, body)
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

end
