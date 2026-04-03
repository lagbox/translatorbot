defmodule Translator.UserPrefs do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def get(user_id), do: GenServer.call(__MODULE__, {:get, user_id})

  def bump(user_id, lang), do: GenServer.cast(__MODULE__, {:bump, user_id, lang})

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:get, user_id}, _from, state) do
    {:reply, Map.get(state, user_id, []), state}
  end

  @impl true
  def handle_cast({:bump, user_id, lang}, state) do
    langs =
      state
      |> Map.get(user_id, [])
      |> Enum.reject(&(&1 == lang))
      |> List.insert_at(0, lang)
      |> Enum.take(5)

    {:noreply, Map.put(state, user_id, langs)}
  end
end
