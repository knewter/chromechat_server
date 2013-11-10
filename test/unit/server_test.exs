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

  test "listing channels" do
    channel = ChromechatServer.ChannelRecord.new(name: "bosshack123")
    server_state = ChromechatServer.ServerState.new(channels: [channel])
    {:ok, server_pid} = ChromechatServer.Server.start_link(server_state)
    assert ["bosshack123"] == ChromechatServer.Server.channel_list(server_pid)
  end

  test "joining a channel" do
    {:ok, server_pid} = ChromechatServer.Server.start_link
    username = "tester"
    channel_name = "bosshack"
    ChromechatServer.Server.connect(server_pid, username)
    ChromechatServer.Server.join(server_pid, channel_name)
    assert ChromechatServer.Server.channel_list(server_pid) == [channel_name]
  end
end
