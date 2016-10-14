defmodule Model.Account.Request do
  @moduledoc """
  Account request object
  """
  @derive [Poison.Encoder]
  defstruct [:first_name, :last_name, :email]

  def validate(request) do
    unless request.first_name, do: throw [message: "First Name Missing", http_code: 400]
    unless request.last_name, do: throw [message: "Last Name Missing", http_code: 400]
    unless request.email, do: throw [message: "Email Missing", http_code: 400]
  end
end
