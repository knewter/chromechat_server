defmodule ChromechatServer.ChannelTest do
  use ExUnit.Case

  setup do
    {:ok, self_pid: self()}
  end

  test "A client can connect to the server, which adds its User to the listeners list.", meta do
    initial_state = ChromechatServer.ChannelState.new
    knewter = new_user(meta[:self_pid])
    state_with_user = initial_state.listeners([knewter])
    assert {:reply, :ok, state_with_user} == ChromechatServer.Channel.handle_call({:join, new_user(meta[:self_pid])}, {meta[:self_pid], []}, initial_state)
  end

  test "A client can list the connected users.", meta do
    knewter = new_user(meta[:self_pid])
    state_with_user = ChromechatServer.ChannelState.new(listeners: [knewter])
    assert {:reply, ["knewter"], state_with_user} == ChromechatServer.Channel.handle_call(:nicklist, { meta[:self_pid], [] }, state_with_user )
  end

  def new_user(pid) do
    ChromechatServer.User.new(username: "knewter", pid: pid)
  end
end
