defmodule Controller.About do
  @moduledoc """
  Example About controller with sub enpoint route and failover 404 matcher
  all endpoints are aliased with `/about/*` based on Router.Base
  """
  alias Response.Json, as: Json
  use Plug.Router
  plug :match
  plug :dispatch

  get "/:name" do
    Json.render(conn, body: %{name: name, stuff: "foo"})
  end

  match _ do
    Json.render(conn, status: 404)
  end
end
