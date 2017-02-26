defmodule Response.Json do
  @moduledoc """
  Poison Encoder for handling json response bodies with status code
  sets default values for `body=%{}` and `status=200`
  supports skipping one or both extra params
  """
  import Plug.Conn

  @spec render(Plug.Conn) :: no_return
  @spec render(Plug.Conn, body: Map.t) :: no_return
  @spec render(Plug.Conn, status: pos_integer) :: no_return
  @spec render(Plug.Conn, body: Map.t, status: pos_integer) :: no_return
  @doc """
  This function renders a result back to an incoming connection

  ## Parameters
  - conn - expectes `Plug.Conn`
  - body - response body `Map` or `String` that is parsed into Json
  - status - http status code `Integer`
  """
  def render(conn), do: renderp(conn, %{}, 200)
  def render(conn, body: body), do: renderp(conn, body, 200)
  def render(conn, status: status), do: renderp(conn, %{}, status)
  def render(conn, body: body, status: status), do: renderp(conn, body, status)

  @spec parse(Plug.Conn, type: any) :: any
  @spec parse(Plug.Conn) :: Map.t
  @doc """
  This function parses an incoming json response body

  ## Parameters
  - conn - expectes `Plug.Conn`
  - type - passed in type to render the incoming payload as
  """
  def parse(conn, type: type), do: parsep(conn, options: %{as: type})
  def parse(conn),             do: parsep(conn, options: %{})

  @spec fail(Plug.Conn) :: no_return
  @spec fail(
    Plug.Conn,
    %{message: String.t, http_code: pos_integer}
  ) :: no_return
  @doc """
  This function sends a failure message to a `Plug.Conn` connected client

  ## Parameters
  - conn - expects `Plug.Conn`
  - message: `Map` or `String` error message to report to client
  - http_code: `Integer` http status code to send to client
  """
  def fail(conn), do: failp(conn, 500, "500 Server Error")
  def fail(conn, %{message: message, http_code: http_code}), do: failp(conn, http_code, message)
  def fail(conn, %{message: message}),     do: failp(conn, 500, message)
  def fail(conn, %{http_code: http_code}), do: failp(conn, http_code, "#{http_code}")
  def fail(conn, payload), do: failp(conn, 500, payload)

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
  defp parsep(conn, options: options) do
    {:ok, body, _} = Connection.read_body(conn, length: 1_000_000)
    Poison.decode!(body, options)
  end

end
