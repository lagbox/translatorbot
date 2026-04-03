defmodule Translator.System.MessageLifecycle do
  use GenServer

  alias Nostrum.Api.Message

  @default_ttl 10_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def schedule_delete(message, ttl \\ @default_ttl) do
    GenServer.cast(__MODULE__, {:schedule, message, ttl})
  end

  def cancel_delete(message_id) do
    GenServer.cast(__MODULE__, {:cancel, message_id})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:schedule, message, ttl}, state) do
    timer_ref = Process.send_after(self(), {:delete, message.id}, ttl)

    new_state =
      Map.put(state, message.id, %{
        time: timer_ref,
        channel_id: message.channel_id
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

  def handle_info({:delete, message_id}, state) do
    case Map.pop(state, message_id) do
      {nil, state} ->
        {:noreply, state}

      {%{channel_id: channel_id}, new_state} ->
        Message.delete(channel_id, message_id)
        {:noreply, new_state}
    end
  end
end
