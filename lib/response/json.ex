defmodule Response.Json do
  import Plug.Conn

  def render(conn), do: rend(conn, %{}, 200)
  def render(conn, body: body), do: rend(conn, body, 200)
  def render(conn, status: status), do: rend(conn, %{}, status)
  def render(conn, body: body, status: status), do: rend(conn, body, status)

  #Private

  defp rend(conn, body, status) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(body))
  end

end
