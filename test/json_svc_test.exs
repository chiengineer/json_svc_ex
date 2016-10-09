defmodule JsonSvcTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Router.Base.init([])
  test "GET / returns service name" do
    conn = conn(:get, "/")
    conn = Router.Base.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.match?(conn.resp_body, ~r/json_svc_ex/)
  end

  test "GET /_health returns OK" do
    conn = conn(:get, "/_health")
    conn = Router.Base.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.match?(conn.resp_body, ~r/ok/)
  end

  test "GET /about/:foo returns foo" do
    conn = conn(:get, "/about/foo")
    conn = Router.Base.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.match?(conn.resp_body, ~r/foo/)
  end

  test "GET /about/:foo/bar returns 404" do
    conn = conn(:get, "/about/foo/bar")
    conn = Router.Base.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  test "GET /randomunknownroute returns 404" do
    conn = conn(:get, "/randomunknownroute")
    conn = Router.Base.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
