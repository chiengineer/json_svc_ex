defmodule Controller.About do
  use Plug.Router
  plug :match
  plug :dispatch

  get "/:name" do
    Response.Json.render(conn, body: %{name: name, stuff: "foo"})
  end

  match _ do
    Response.Json.render(conn, status: 404)
  end
end
