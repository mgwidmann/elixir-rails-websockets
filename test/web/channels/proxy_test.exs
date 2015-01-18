defmodule ElixirRailsWebsockets.ProxyChannelTest do
  use ExUnit.Case, async: true
  import Mock
  alias ElixirRailsWebsockets.ProxyChannel, as: Proxy
  alias Phoenix.Socket
  alias Phoenix.Socket.Message

  test "parsing simple json" do
    assert Proxy.parse("{\"key\": \"value\"}") == %{"key" => "value"}
  end

  test "parsing bad json" do
    assert Proxy.parse("{'key': 'value'}") == %{text: "{'key': 'value'}"}
  end

  test "parsing html" do
    assert Proxy.parse("<p>Text</p>") == %{html: "<p>Text</p>"}
  end

  test "parsing text" do
    assert Proxy.parse("Text") == %{text: "Text"}
  end

  test "polls" do
    with_mock HTTPoison, [get: &get_url/1] do
      send_to = self
      pid = spawn_link fn -> Proxy.poll(%Socket{pid: send_to}) end
      send(pid, :check)
      send(pid, :exit)
      assert_receive {:socket_reply, %Message{event: "data:update"}}
    end
  end

  # {:ok, %HTTPoison.Response{status_code: 200, body: body}}
  test "get url successful" do
    with_mock HTTPoison, [get: &get_url/1] do
      assert Proxy.get("example.com") == %{}
    end
  end

  # {:ok, %HTTPoison.Response{status_code: 404}}
  test "get url 404" do
    with_mock HTTPoison, [get: &get_404/1] do
      assert Proxy.get("example.com") == %{error: "Not found: example.com"}
    end
  end

  # {:error, %HTTPoison.Error{reason: {:closed, body}}}
  test "get url closed connection" do
    with_mock HTTPoison, [get: &get_closed/1] do
      assert Proxy.get("example.com") == %{}
    end
  end

  # {:error, %HTTPoison.Error{reason: reason}}
  test "get url error" do
    with_mock HTTPoison, [get: &get_error/1] do
      assert Proxy.get("example.com") == %{error: "{:broke, \"internet\"}"}
    end
  end

  def get_url(_url), do: {:ok, %HTTPoison.Response{status_code: 200, body: "{}"}}
  def get_404(_url), do: {:ok, %HTTPoison.Response{status_code: 404, body: "Not Found"}}
  def get_closed(_url), do: {:error, %HTTPoison.Error{reason: {:closed, "{}"}}}
  def get_error(_url), do: {:error, %HTTPoison.Error{reason: {:broke, "internet"}}}

  test "replies with initial data" do
    Proxy.reply_with_initial_data(%Socket{pid: self, assigns: %{data: %{data: "data"}}})
    assert_received {:socket_reply, %Message{event: "data:update", payload: %{data: "data"}}}
  end

  test "initialize socket" do
    with_mock HTTPoison, [get: &get_url/1] do
      assert Proxy.initialize_socket("example.com", %Socket{}) == %Socket{assigns: %{url: "example.com", data: %{}}}
    end
  end

  test "check timeout valid number" do
    assert Proxy.check_timeout("1000") == {:integer, 1_000}
  end

  test "check timeout valid number, bad range" do
    assert Proxy.check_timeout("99") == :other
  end

  test "check timeout not a number" do
    assert Proxy.check_timeout("foo") == :other
  end

  test "check timeout not an integer" do
    assert Proxy.check_timeout("1000.5") == {:integer, 1_000}
  end

  test "check timeout negative integer" do
    assert Proxy.check_timeout("-1000") == :other
  end

  test "check timeout large number" do
    assert Proxy.check_timeout("86400001") == :other
  end

  test "check timeout large number inside range" do
    assert Proxy.check_timeout("86400000") == {:integer, 86_400_000}
  end

  test "join with good timeout" do
    with_mock HTTPoison, [get: &get_url/1] do
      assert {:ok, %Socket{}} = Proxy.join("1000", "example.com", %Socket{pid: self})
      assert_received {:socket_reply, %Message{event: "data:update", payload: %{}}}
    end
  end

  test "join with bad timeout" do
    with_mock HTTPoison, [get: &get_url/1] do
      assert {:error, %Socket{}, "Not a valid" <> _} = Proxy.join("bad", "example.com", %Socket{pid: self})
      refute_received {:socket_reply, %Message{event: "data:update", payload: %{}}}
    end
  end
end
