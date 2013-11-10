defmodule ChromechatServer.Server do
  use GenServer.Behaviour

  # Public API
  def start_link(server_state // ChromechatServer.ServerState.new) do
    :gen_server.start_link(__MODULE__, server_state, [])
  end

  def connect(server_pid, username) do
    :gen_server.call(server_pid, {:connect, username})
  end

  def disconnect(server_pid) do
    :gen_server.call(server_pid, :disconnect)
  end

  def channel_list(server_pid) do
    :gen_server.call(server_pid, :channel_list)
  end

  def join(server_pid, channel_name) do
    :gen_server.call(server_pid, {:join, channel_name})
  end

  # GenServer API
  def init(server_state) do
    { :ok, server_state }
  end

  def handle_call({:connect, username}, from, state) do
    {status, new_state} = add_user(username, from, state)
    {:reply, status, new_state}
  end
  def handle_call(:disconnect, from, state) do
    new_state = remove_user(from, state)
    {:reply, :ok, new_state}
  end
  def handle_call(:channel_list, _from, state) do
    channel_names = state.channels |> Enum.map(fn(channel) -> channel.name end)
    {:reply, channel_names, state}
  end
  def handle_call({:join, channel_name}, from, state) do
    {from_pid, _} = from
    case user_from_pid(from_pid, state) do
      :not_found -> {:reply, :user_not_found, state}
      user ->
        case channel_from_name(channel_name, state) do
          :not_found ->
            {:ok, channel_pid} = ChromechatServer.Channel.start_link
            new_state = state.update_channels(fn(channels) -> [ChromechatServer.ChannelRecord.new(name: channel_name, pid: channel_pid) | channels] end)
            {:reply, ChromechatServer.Channel.join(channel_pid, user), new_state}
          channel -> {:reply, ChromechatServer.Channel.join(channel.pid, user), state}
        end
    end
  end

  # Private bits...
  defp add_user(username, {from_pid, _ref}, state) do
    case Enum.any?(state.listeners, fn(user) -> user.username == username end) do
      true -> {:duplicate_username, state}
      false ->
        new_user = ChromechatServer.User.new(username: username, pid: from_pid)
        new_state = state.update_listeners(fn(listeners) -> listeners ++ [new_user] end)
        {:ok, new_state}
    end
  end

  defp remove_user({from_pid, _ref}, state) do
    old_listeners = state.listeners
    new_listeners = old_listeners |> Enum.filter(fn(user) -> user.pid != from_pid end)
    state.listeners(new_listeners)
  end

  defp user_from_pid(from_pid, state) do
    case state.listeners |> Enum.filter(fn(user) -> user.pid == from_pid end) do
      [] -> :not_found
      [user | _] -> user
    end
  end

  defp channel_from_name(name, state) do
    case state.channels |> Enum.filter(fn(channel) -> channel.name == name end) do
      [] -> :not_found
      [channel | _] -> channel
    end
  end
end
