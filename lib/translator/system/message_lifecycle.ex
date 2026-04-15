defmodule Translator.System.MessageLifecycle do
  use GenServer

  alias Nostrum.Api.Message

  @default_ttl 60_000

  @delete_emoji "🗑️"
  @pin_emoji "📌"
  @emojis [@pin_emoji, @delete_emoji]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def schedule_delete(message, owner_id, ttl \\ @default_ttl) do
    GenServer.cast(__MODULE__, {:schedule, message, owner_id, ttl})
  end

  def cancel_delete(message_id) do
    GenServer.cast(__MODULE__, {:cancel, message_id})
  end

  def pin(message_id) do
    GenServer.cast(__MODULE__, {:pin, message_id})
  end

  def can_delete?(message_id, user_id) do
    GenServer.call(__MODULE__, {:can_delete, message_id, user_id})
  end

  def delete_if_owner(message_id, user_id) do
    GenServer.cast(__MODULE__, {:delete_if_owner, message_id, user_id})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:schedule, message, owner_id, ttl}, state) do
    timer_ref = Process.send_after(self(), {:delete, message.id}, ttl)

    new_state =
      Map.put(state, message.id, %{
        time: timer_ref,
        channel_id: message.channel_id,
        owner_id: owner_id,
        pinned?: false
      })

    {:noreply, new_state}
  end

  def handle_cast({:cancel, message_id}, state) do
    case Map.pop(state, message_id) do
      {nil, state} ->
        {:noreply, state}

      {%{time: timer_ref}, new_state} ->
        Process.cancel_timer(timer_ref)
        {:noreply, new_state}
    end
  end

  def handle_cast({:pin, message_id}, state) do
    case Map.get(state, message_id) do
      %{time: timer_ref} = data ->
        Process.cancel_timer(timer_ref)

        new_state =
          Map.put(state, message_id, %{
            data
            | time: nil,
              pinned?: true
          })

        {:noreply, new_state}

      nil ->
        {:noreply, state}
    end
  end

  def handle_cast({:delete_if_owner, message_id, user_id}, state) do
    dbg(state)

    case Map.get(state, message_id) do
      %{owner_id: ^user_id, time: timer_ref} = data ->
        if !is_nil(timer_ref), do: Process.cancel_timer(timer_ref)

        Task.start(fn ->
          delete_emoji_reactions(data.channel_id, message_id)
        end)

        Process.send_after(self(), {:delete, message_id}, 2_000)

        {:noreply, state}

      _ ->
        {:noreply, state}
    end

    {:noreply, state}
  end

  defp delete_emoji_reactions(channel_id, message_id) do
    Enum.each(@emojis, fn emoji ->
      Message.delete_emoji_reactions(channel_id, message_id, encode_emoji(emoji))
    end)
  end

  def handle_info({:delete, message_id}, state) do
    case Map.pop(state, message_id) do
      {nil, state} ->
        {:noreply, state}

      {%{channel_id: channel_id}, new_state} ->
        Message.delete(channel_id, message_id)
        {:noreply, new_state}
    end
  end

  def handle_call({:can_delete, message_id, user_id}, _from, state) do
    result =
      case Map.get(state, message_id) do
        %{owner_id: ^user_id} -> true
        _ -> false
      end

    {:reply, result, state}
  end

  defp encode_emoji(emoji) do
    URI.encode(emoji, &URI.char_unreserved?/1)
  end
end
