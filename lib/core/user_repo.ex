defmodule Bot.Core.UserRepo do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get(id), do: GenServer.call(__MODULE__, {:get, id})
  def put(id, user), do: GenServer.cast(__MODULE__, {:put, id, user})
  def update(id, fun), do: GenServer.cast(__MODULE__, {:update, id, fun})
  def delete(id), do: GenServer.cast(__MODULE__, {:delete, id})
  def all, do: GenServer.call(__MODULE__, :all)

  def from_discord_user(user) do
    user |> Map.from_struct()
  end

  def add_language(user, language) do
    Map.put(user, :language, language)
  end

  def init(state), do: {:ok, state}

  def handle_call({:get, id}, _from, state) do
    {:reply, Map.get(state, id), state}
  end

  def handle_call({:get_or_create, id, default_fun}, _from, state) do
    case Map.get(state, id) do
      nil ->
        user = default_fun.()
        {:reply, user, Map.put(state, id, user)}

      user ->
        {:reply, user, state}
    end
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:put, id, user}, state) do
    {:noreply, Map.put(state, id, user)}
  end

  def handle_cast({:update, id, fun}, state) do
    {:noreply, Map.update(state, id, nil, fun)}
  end

  def handle_cast({:delete, id}, state) do
    {:noreply, Map.delete(state, id)}
  end
end
