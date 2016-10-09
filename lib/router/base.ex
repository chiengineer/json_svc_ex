defmodule Router.Base do
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/about", to: Controller.About
  forward "/",      to: Controller.Root
end
