defmodule AppError do
  defexception [:message, :http_code, :hb_options]

  def exception(%{message: msg, http_code: code, hb_options: hb}), do: exceptionp(msg, code, hb)
  def exception(%{http_code: code}), do: exceptionp("Server Error", code, %{})
  def exception(%{hb_options: hb}), do: exceptionp("Server Error", 500, hb)
  def exception(%{message: msg}), do: exceptionp(msg, 500, %{})

  defp exceptionp(message, http_code, hb_options) do
    %AppError{message: message, http_code: http_code, hb_options: hb_options}
  end
end
