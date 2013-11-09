defmodule ChromechatServer.Server do
  use GenServer.Behaviour

  # Public API
  def start_link do
    :gen_server.start_link(__MODULE__, ChromechatServer.ServerState.new, [])
  end

  def connect(server_pid, username) do
    :gen_server.call(server_pid, {:connect, username})
  end

  def disconnect(server_pid) do
    :gen_server.call(server_pid, :disconnect)
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
end
