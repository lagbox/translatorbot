defmodule Translator.InFlight do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def run(key, fun) do
    GenServer.call(__MODULE__, {:run, key, fun}, :infinity)
  end

  def init(state), do: {:ok, state}

  def handle_call({:run, key, fun}, from, state) do
    case Map.get(state, key) do
      nil ->
        Task.start(fn ->
          result = safe_execute(fun)
          GenServer.cast(__MODULE__, {:complete, key, result})
        end)

        {:noreply, Map.put(state, key, [from])}

      waiters ->
        {:noreply, Map.put(state, key, [from | waiters])}
    end
  end

  def handle_cast({:complete, key, result}, state) do
    case Map.pop(state, key) do
      {nil, state} ->
        {:noreply, state}

      {waiters, new_state} ->
        Enum.each(waiters, fn from ->
          GenServer.reply(from, result)
        end)

        {:noreply, new_state}
    end
  end

  defp safe_execute(fun) do
    try do
      fun.()
    rescue
      e -> {:error, e}
    catch
      _, reason -> {:error, reason}
    end
  end
end
