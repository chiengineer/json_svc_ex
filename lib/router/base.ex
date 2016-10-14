defmodule Router.Base do
  @moduledoc """
  Base Router, handles all forwarding requests to separate controllers based on
  each controller's defined path
  """
  use Plug.Router
  use Plug.ErrorHandler

  alias Response.Json, as: Json

  plug :match
  plug :dispatch

  forward "/about", to: Controller.About
  forward "/account", to: Controller.Account
  forward "/",      to: Controller.Root

  def handle_errors(conn, %{kind: kind, reason: reason, stack: _stack}) do
    status = set_status_from_kind(kind)
    Json.fail(conn, status, message: reason)
  end

  defp set_status_from_kind(kind) do
    if kind == :throw, do: 400, else: 500
  end
end
