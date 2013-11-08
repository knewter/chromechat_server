# Feature tests go through the Dynamo.under_test
# and are meant to test the full stack.
defmodule HomeTest do
  use ChromechatServer.TestCase
  use Dynamo.HTTP.Case

  test "returns OK" do
    conn = get("/")
    assert conn.status == 200
  end

  test "returns a list of available resources" do
    conn = get("/")
    assert_json_body conn, [
      links: [
        join_channel: "/join_channel"
      ]
    ]
  end

  def assert_json_body conn, unserialized_structure do
    assert conn.sent_body == JSON.encode(unserialized_structure)
  end
end
