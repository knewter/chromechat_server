defmodule ChromechatServer.Channel do
  use GenServer.Behaviour

  # Public API
  def start_link do
    :gen_server.start_link(__MODULE__, ChromechatServer.ChannelState.new, [])
  end

  def handle_call({:join, user=ChromechatServer.User}, from, state) do
    {status, new_state} = add_user(user, from, state)
    broadcast_join_message(user.username, new_state)
    {:reply, status, new_state}
  end

  # GenServer API
  def init(state) do
    {:ok, state}
  end

  # Private bits
  defp add_user(user, _from, state) do
    case has_user?(user.username, state) do
      true -> {:duplicate_username, state}
      false -> {:ok, state.listeners([user|state.listeners])}
    end
  end

  defp has_user?(username, state) do
    Enum.any?(state.listeners, fn(user) -> user.username == username end)
  end

  defp broadcast_join_message(username, state) do
    message = build_message("#{username} has joined.")
    broadcast(message, state)
  end

  defp broadcast(message, to_pid) do
    to_pid <- message
  end

  defp build_message(message_text) do
    ChromechatServer.Message.new(username: "system", text: message_text)
  end
end
