defmodule Controller.About do
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
