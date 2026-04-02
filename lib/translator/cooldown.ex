defmodule Translator.Cooldown do
  use GenServer

  @ttl 3_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def allow?(message_id, lang) do
    GenServer.call(__MODULE__, {:check, message_id, lang})
  end

  def init(state), do: {:ok, state}

  def handle_call({:check, msg_id, lang}, _from, state) do
    now = System.monotonic_time(:millisecond)
    key = {msg_id, lang}

    case Map.get(state, key) do
      nil ->
        {:reply, true, Map.put(state, key, now)}

      last when now - last > @ttl ->
        {:reply, true, Map.put(state, key, now)}

      _ ->
        {:reply, false, state}
    end
  end
end
