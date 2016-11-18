defmodule Model.Account.RequestTest do
  use ExUnit.Case, async: true
  alias Model.Account.Request, as: Request
  doctest Request

  test "throws error for missing first_name" do
    test_model = %Request{
      email: "joe@bob.com",
      last_name: "Bob"}
    assert_raise AppError, ~r/first_name is missing/, fn ->
      Request.validate!(test_model)
    end
  end

  test "throws error for missing last_name" do
    test_model = %Request{
      email: "joe@bob.com",
      first_name: "Bob"}
    assert_raise AppError, ~r/last_name is missing/, fn ->
      Request.validate!(test_model)
    end
  end

  test "throws error for missing email" do
    test_model = %Request{
      last_name: "Jim",
      first_name: "Bob"}
    assert_raise AppError, ~r/email is missing/, fn ->
      Request.validate!(test_model)
    end
  end
end
