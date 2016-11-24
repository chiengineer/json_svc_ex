require Honeybadger

defmodule ErrorReporter.Honeybadger do
  @moduledoc """
    Reports errors to `Honeybadger` adds option to ignore report flow
  """

  @doc ~S"""
   Ignores `Honeybadger` messages if `%{options: %{ignore: true}}`
  ## Examples
    iex> ErrorReporter.Honeybadger.report(
    ...> nil,
    ...> context: nil,
    ...> stacktrace: nil,
    ...> options: %{ignore: true})
    {:ok, :ignored}
  """

  @spec report(Exception.t) :: {:ok, :sent}
  @spec report(Exception.t, context: %{}, stacktrace: %{}) :: {:ok, :sent}
  @spec report(Exception.t, options: %{ignore: boolean}) :: {:ok, :ignored}

  def report(exception), do: reportp(exception, nil, nil)
  def report(exception, context: ctx), do: reportp(exception, ctx, nil)
  def report(exception, stacktrace: stk), do: reportp(exception, nil, stk)
  def report(_excpt, context: _ctx, stacktrace: _stk, options: %{ignore: true}), do: {:ok, :ignored}

  def report(exception, context: context, stacktrace: stack, options: _opts) do
    reportp(exception, context, stack)
    {:ok, :sent}
  end

  defp reportp(exception, context, stack) do
    Honeybadger.notify(exception, context, stack)
    {:ok, :sent}
  end
end
