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

  def handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    Json.fail(conn, reason)
  end
end
