defmodule AppError do
  @moduledoc """
  Application error with support for explicitly setting `http_code` and
  an option to ignore error in `Honeybadger`
  """
  defexception [:message, :http_code, :hb_options]

  @spec exception(%{
    message: String.t,
    code: pos_integer,
    hb_options: %{ignore: boolean}
  }) :: Exception.t
  @doc """
  This Function is used to handle an application error and explicitly set an
  http response code and any honeybadger options
  """
  def exception(%{message: msg, http_code: code, hb_options: hb}), do: exceptionp(msg, code, hb)
  def exception(%{http_code: code}), do: exceptionp("Server Error", code, %{})
  def exception(%{hb_options: hb}), do: exceptionp("Server Error", 500, hb)
  def exception(%{message: msg}), do: exceptionp(msg, 500, %{})

  defp exceptionp(message, http_code, hb_options) do
    %AppError{message: message, http_code: http_code, hb_options: hb_options}
  end
end
