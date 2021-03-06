defmodule Router.Base do
  @moduledoc """
  Base Router, handles all forwarding requests to separate controllers based on
  each controller's defined path

  # Routes
  - `/about` - forwards to `Controller.About`
  - `/account` - forwards to `Controller.Account`
  - `/` - forwards to `Controller.Root`
  """
  use Plug.Router
  use Plug.ErrorHandler

  alias Response.Json, as: Json
  alias ErrorReporter.Honeybadger, as: ErrorReporter

  plug :match
  plug :dispatch

  forward "/about", to: Controller.About
  forward "/account", to: Controller.Account
  forward "/",      to: Controller.Root

  @spec handle_errors(Plug.Conn, list) :: no_return
  @doc """
  raised errors from http requests are handled here

  - `Response.Json.fail/2` sent to `Plug.Conn` client
  - error reported via `ErrorReporter.Honeybadger`
  """
  def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    Json.fail(conn, reason)
    ErrorReporter.report(
      %{kind: kind, message: reason[:message]},
      context: %{error: reason[:context], connection: conn},
      stacktrace: stack,
      options: reason[:hb_options]
      )
  end
end
