defmodule JsonSvc.Sockets.Endpoint do

  use Phoenix.Endpoint, otp_app: :json_svc_ex_sockets

    socket :_, JsonSvc.Sockets
    alias JsonSvc.Channels.Room, as: General
    alias JsonSvc.Channels.RequestCreate, as: Account

    def init(_, _req, _opts) do
      {:upgrade, :protocol, :cowboy_websocket}
    end

    @timeout 60_000 # terminate if no activity for one minute

    #Called on websocket connection initialization.
    def websocket_init(_type, req, _opts) do
      state = %{}
      {:ok, req, state, @timeout}
    end

    def websocket_handle({:text, "ping"}, req, state) do
      {:reply, {:text, "pong"}, req, state}
    end

    def websocket_handle({:text, message}, req, %{channel: "room:" <> name}) do
      {:noreply, socket} = General.handle_in(
        "new_msg", %{"body" => message}, req, %{channel: "room:" <> name})
      {:ok, socket, %{channel: "room:" <> name}}
    end

    def websocket_handle({:text, "room:" <> name}, req, _state) do
      {:ok, socket} = General.join("room:" <> name, :req, req)
      {:ok, socket, %{channel: "room:" <> name}}
    end

    def websocket_handle({:text, "request_create:" <> token}, req, _state) do
      {:ok, socket} = Account.join(token, :req, req)
      {:ok, socket, %{channel: "request_create:" <> token}}
    end

    # Handle other messages from the browser - don't reply
    def websocket_handle({:text, _message}, req, state) do
      {:ok, req, state}
    end

    # Format and forward elixir messages to client
    def websocket_info(message, req, state) do
      {:reply, {:text, message}, req, state}
    end

    def websocket_terminate(reason, req, %{channel: "request_create:" <> token}) do
      Account.leave(token, reason, req)
      :ok
    end

    # No matter why we terminate, remove all of this pids subscriptions
    def websocket_terminate(_reason, _req, _state) do
      :ok
    end
end
