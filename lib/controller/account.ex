defmodule Controller.Account do
  @moduledoc """
  Account controller manages details of account modifications
  TODO: GET - get read optimized account details

  ## Routes
  - `POST /account/` - creates account details request
      - validates incoming payload `Model.Account.Request.validate!/1`
      - creates kafka message of validated payload
        `KafkaHandlers.Account.RequestCreate.publish/1`
      - returns acceptance payload `Response.Json.render/2`
  - All other results return a `404` error
  """
  alias Response.Json, as: Json
  alias Model.Account.Request, as: Request
  alias KafkaHandlers.Account.RequestCreate, as: Kafka
  use Plug.Router
  plug :match
  plug :dispatch

  post "/" do
    account_request = Json.parse(conn, type: %Request{})
    Request.validate!(account_request)
    {:ok , request_payload} = Kafka.publish(account_request)
    Json.render(
      conn,
      body: %{accepted: request_payload})
  end

  match _ do
    Json.render(conn, status: 404)
  end
end
