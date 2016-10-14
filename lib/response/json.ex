defmodule Response.Json do
  @moduledoc """
  Poison Encoder for handling json response bodies with status code
  sets default values for `body=%{}` and `status=200`
  supports skipping one or both extra params
  """
  import Plug.Conn

  def render(conn), do: rend(conn, %{}, 200)
  def render(conn, body: body), do: rend(conn, body, 200)
  def render(conn, status: status), do: rend(conn, %{}, status)
  def render(conn, body: body, status: status), do: rend(conn, body, status)

  def parse(conn, type: type), do: prse(conn, options: %{as: type})
  def parse(conn),             do: prse(conn, options: %{})

  def fail(conn, status, message: message) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(%{error: message}))
  end

  #Private

  defp rend(conn, body, status) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(body))
  end

  alias Plug.Conn, as: Connection
  defp prse(conn, options: options) do
    {:ok, body, _} = Connection.read_body(conn, length: 1_000_000)
    Poison.decode!(body, options)
  end

end
