defmodule Controller.Account do
  @moduledoc """
  Account controller manages details of account modifications
  POST - request create of Account details
  PATCH - request modification of account details
  DELETE - request removal of Account details
  TODO: GET - get read optimized account details
  """
  alias Response.Json, as: Json
  alias Model.Account.Request, as: Request
  use Plug.Router
  plug :match
  plug :dispatch

  post "/" do
    account_request = Json.parse(conn, type: Request)
    Request.validate!(account_request)
    Json.render(
      conn,
      body: %{accepted: account_request})
  end

  match _ do
    Json.render(conn, status: 404)
  end
end