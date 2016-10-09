defmodule Controller.Root do
  @moduledoc """
  Root (/) and health endpoints to return service details and act as an
  external watchdog resource
  """
  alias Response.Json, as: Json
  use Plug.Router
  plug :match
  plug :dispatch

  get "/_health" do
    Json.render(conn, body: %{status: "ok"})
  end

  get "/" do
    Json.render(conn, body: %{service: "json_svc_ex"})
  end

  match _ do
    Json.render(conn, status: 404)
  end
end
