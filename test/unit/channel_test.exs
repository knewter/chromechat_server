defmodule ChromechatServer.ChannelTest do
  use ExUnit.Case

  test "A client joins and is announced to all attached listeners." do
    {:ok, pid} = ChromechatServer.Channel.start_link
    ChromechatServer.Channel.join(pid, new_user(self))
    expected_message = ChromechatServer.Message.new(username: "system", text: "knewter has joined.")
    assert_received expected_message
  end

  test "A client parts and is announced to all attached listeners." do
    {:ok, pid} = ChromechatServer.Channel.start_link
    ChromechatServer.Channel.join(pid, new_user(self))
    ChromechatServer.Channel.part(pid)
    expected_message = ChromechatServer.Message.new(username: "system", text: "knewter has parted.")
    assert_received expected_message
  end

  test "A client sees itself in the nicklist after joining." do
    {:ok, pid} = ChromechatServer.Channel.start_link
    ChromechatServer.Channel.join(pid, new_user(self))
    assert ["knewter"] == ChromechatServer.Channel.nicklist(pid)
  end

  test "A client can connect to the server, which adds its User to the listeners list." do
    initial_state = ChromechatServer.ChannelState.new
    knewter = new_user(self)
    state_with_user = initial_state.listeners([knewter])
    assert {:reply, :ok, state_with_user} == ChromechatServer.Channel.handle_call({:join, new_user(self)}, {self, []}, initial_state)
  end

  test "A client can list the connected users." do
    knewter = new_user(self)
    state_with_user = ChromechatServer.ChannelState.new(listeners: [knewter])
    assert {:reply, ["knewter"], state_with_user} == ChromechatServer.Channel.handle_call(:nicklist, { self, [] }, state_with_user )
  end

  test "A client can send messages." do
    knewter = new_user(self)
    state_with_user = ChromechatServer.ChannelState.new(listeners: [knewter])
    assert {:noreply, state_with_user} == ChromechatServer.Channel.handle_cast({:send, self, "some message"}, state_with_user)
  end

  def new_user(pid) do
    ChromechatServer.User.new(username: "knewter", pid: pid)
  end
end
