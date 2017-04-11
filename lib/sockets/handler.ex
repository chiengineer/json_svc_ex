defmodule JsonSvc.Sockets.Endpoint do

  use Phoenix.Endpoint, otp_app: :json_svc_ex_sockets

    socket :_, JsonSvc.Sockets

    def init(_, _req, _opts) do
      {:upgrade, :protocol, :cowboy_websocket}
    end

    @timeout 60_000 # terminate if no activity for one minute

    #Called on websocket connection initialization.
    def websocket_init(_type, req, _opts) do
      state = %{}
      {:ok, req, state, @timeout}
    end

    # Handle 'ping' messages from the browser - reply
    def websocket_handle({:text, "ping"}, req, state) do
      {:reply, {:text, "pong"}, req, state}
    end

    def websocket_handle({:text, message}, req, %{channel: "room:" <> name}) do
      {:noreply, socket} = JsonSvc.Channels.Room.handle_in("new_msg", %{"body" => message}, req, %{channel: "room:"<>name})
      {:ok, socket, %{channel: "room:"<>name}}
    end

    def websocket_handle({:text, "room:" <> name}, req, state) do
      {:ok, socket} = JsonSvc.Channels.Room.join("room:" <> name, get_socket_keyp(req), req)
      {:ok, socket, %{channel: "room:" <> name}}
    end

    # Handle other messages from the browser - don't reply
    def websocket_handle({:text, message}, req, state) do
      {:ok, req, state}
    end

    # Format and forward elixir messages to client
    def websocket_info(message, req, state) do
      {:reply, {:text, message}, req, state}
    end

    # No matter why we terminate, remove all of this pids subscriptions
    def websocket_terminate(_reason, _req, _state) do
      :ok
    end

    def get_socket_keyp(socket) do
      {:http_req, port_id, :ranch_tcp, :keepalive,
       socket_pid, _method, :"HTTP/1.1",
       {socket_ip, socket_port}, _server_host, _undefined, _4000,
       "/ws", _ndefined, _, _undefined, _array,
       [{"connection", "Upgrade"}, {"upgrade", "websocket"},
        {"host", "localhost:4000"},
        {"sec-websocket-version", "13"},
        {"sec-websocket-key", socket_key},
        {"sec-websocket-extensions",
         "permessage-deflate; client_max_window_bits"}],
       _, _, _, _, _, _, _, _, _, _,_
       } = socket
      socket_key
    end
end

defmodule JsonSvc.Sockets do
  use Phoenix.Socket

  transport :websocket, Phoenix.Transports.WebSocket

  ## Channels
  channel "room:*", JsonSvc.Channels.Room

  def connect(params, socket) do
    {:ok, assign(socket, :user_id, params["user_id"])}
  end

  def id(socket), do: "users_socket:#{socket.assigns.user_id}"

end
