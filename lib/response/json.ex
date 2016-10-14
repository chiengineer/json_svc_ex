defmodule Response.Json do
  @moduledoc """
  Poison Encoder for handling json response bodies with status code
  sets default values for `body=%{}` and `status=200`
  supports skipping one or both extra params
  """
  import Plug.Conn

  def render(conn), do: renderp(conn, %{}, 200)
  def render(conn, body: body), do: renderp(conn, body, 200)
  def render(conn, status: status), do: renderp(conn, %{}, status)
  def render(conn, body: body, status: status), do: renderp(conn, body, status)

  def parse(conn, type: type), do: prse(conn, options: %{as: type})
  def parse(conn),             do: prse(conn, options: %{})

  def fail(conn, message: message, http_code: http_code), do: failp(conn, http_code, message)
  def fail(conn, http_code: status),                do: failp(conn, status, "#{status}")
  def fail(conn, message: body),                    do: failp(conn, 500, body)
  def fail(conn),                                   do: failp(conn, 500, "Server Error")

  #Private

  defp failp(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(%{error: body}))
  end

  defp renderp(conn, body, status) do
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
