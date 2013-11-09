defmodule ChromechatServer.ServerTest do
  use ExUnit.Case

  test "connecting to a server" do
    {:ok, server_pid} = ChromechatServer.Server.start_link
    assert :ok == ChromechatServer.Server.connect(server_pid, "tester")
  end

  test "disconnecting from a server" do
    {:ok, server_pid} = ChromechatServer.Server.start_link
    ChromechatServer.Server.connect(server_pid, "tester")
    assert :ok == ChromechatServer.Server.disconnect(server_pid)
  end
end
