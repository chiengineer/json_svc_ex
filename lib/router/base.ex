defmodule Router.Base do
  @moduledoc """
  Base Router, handles all forwarding requests to separate controllers based on
  each controller's defined path
  """
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/about", to: Controller.About
  forward "/",      to: Controller.Root
end
