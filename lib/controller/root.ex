defmodule Controller.Root do
  use Plug.Router
  plug :match
  plug :dispatch

  get "/_health" do
    Response.Json.render(conn, body: %{status: "ok"})
  end

  get "/" do
    Response.Json.render(conn, body: %{service: "json_svc_ex"})
  end

  match _ do
    Response.Json.render(conn, status: 404)
  end
end
