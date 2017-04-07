defmodule Response.JsonTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Response.Json, as: Json

  test "render returns default values" do
    conn = conn(:get, "/about/foo")
    result = Json.render(conn)
    assert(result.resp_body == "{}")
    assert(result.status == 200)
  end

  test "render Returns a json response object" do
    conn = conn(:get, "/about/foo")
    result = Json.render(conn, body: "success")
    assert(result.resp_body == "\"success\"")
    assert(result.status == 200)
  end

  test "render can set a specific status code with default message" do
    conn = conn(:get, "/about/foo")
    result = Json.render(conn, status: 204)
    assert(result.resp_body == "{}")
    assert(result.status == 204)
  end

  test "fail returns default values" do
    conn = conn(:get, "/about/foo")
    result = Json.fail(conn)
    assert(result.resp_body =~ "500 Server Error")
    assert(result.status == 500)
  end

  test "fail returns specific error code" do
    conn = conn(:get, "/about/foo")
    result = Json.fail(conn, %{http_code: 522})
    assert(result.resp_body == "{\"error\":\"522\"}")
    assert(result.status == 522)
  end

  test "fail returns specific error message" do
    conn = conn(:get, "/about/foo")
    result = Json.fail(conn, %{message: "This error"})
    assert(result.resp_body == "{\"error\":\"This error\"}")
    assert(result.status == 500)
  end

  test "fail returns specific error message and error code" do
    conn = conn(:get, "/about/foo")
    result = Json.fail(conn, %{message: "This error", http_code: 504})
    assert(result.resp_body == "{\"error\":\"This error\"}")
    assert(result.status == 504)
  end

  test "handles unexpected payload shapes" do
    conn = conn(:get, "/about/foo")
    result = Json.fail(conn, %{unknown_key: "This error"})
    assert(result.resp_body == "{\"error\":{\"unknown_key\":\"This error\"}}")
    assert(result.status == 500)
  end

  test "renders a json payload to a map" do
    conn = conn(:post, "/about/foo", "{\"foo\":\"bar\"}")
             |> put_req_header("content-type", "application/json")
    result = Json.parse(conn)
    assert(result == %{"foo" => "bar"})
  end

  defmodule MockType do
    defstruct [:foo]
  end

  test "renders a json payload to a specific map struct" do
    conn = conn(:post, "/about/foo", "{\"foo\":\"bar\"}")
             |> put_req_header("content-type", "application/json")
    result = Json.parse(conn, type: %MockType{})
    assert(result == %MockType{foo: "bar"})
  end

end
