defmodule Model.Account.Request do
  @moduledoc """
  Account request object

  ## Examples
  ```elixir
  iex> test_model = %Model.Account.Request{
  ...> first_name: "Joe",
  ...> last_name: "Bob",
  ...> email: "joe@bob.com"}
  iex> Model.Account.Request.validate!(test_model)
  {:ok, :valid}

  ```
  """
  @derive [Poison.Encoder]
  @required_keys [:first_name, :last_name, :email]
  defstruct @required_keys

  def validate!(request) do
    validate_array = validate_keysp(@required_keys, request)
    throw_error_for_invalid_entries!(validate_array)
    {:ok, :valid}
  end

  defp throw_error_for_invalid_entries!(validate_array) do
    error_keys = Enum.filter(
      validate_array,
      fn tuple -> elem(tuple, 1) == false end)
    if length(error_keys) > 0,
      do: raise AppError, %{
        message: generate_error_messages(error_keys),
        http_code: 400,
        hb_options: %{ignore: true}}
  end

  defp generate_error_messages(errors) do
    Enum.map(errors, fn err -> "#{elem(err, 0)} is missing." end)
  end

  defp validate_keysp(required, request) do
    Enum.map(
      required,
      fn(k) -> key_presentp(k, Map.get(request, k)) end)
  end

  defp key_presentp(key, value) do
    {key, value != nil}
  end
end
