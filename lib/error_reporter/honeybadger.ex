require Honeybadger

defmodule ErrorReporter.Honeybadger do
  @moduledoc """
  Reports errors to honeybadger adds option to ignore report flow

  iex> ErrorReporter.Honeybadger.report(
  ...> nil,
  ...> context: nil,
  ...> stacktrace: nil,
  ...> options: %{ignore: true})
  {:ok, :ignored}
  """
  def report(exception), do: reportp(exception, nil, nil)
  def report(exception, context: ctx), do: reportp(exception, ctx, nil)
  def report(exception, stacktrace: stk), do: reportp(exception, nil, stk)
  def report(_excpt, context: _ctx, stacktrace: _stk, options: %{ignore: true}) do
    {:ok, :ignored}
  end

  def report(exception, context: context, stacktrace: stack, options: _opts) do
      reportp(exception, context, stack)
  end

  defp reportp(exception, context, stack) do
    Honeybadger.notify(exception, context, stack)
  end
end
