defmodule Bot.Commands.Registry do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def mention(guild_id, name) do
    case get_id(guild_id, name) do
      nil -> "/#{name}"
      id -> "</#{name}:#{id}>"
    end
  end

  def refresh(guild_id) do
    GenServer.cast(__MODULE__, {:refresh, guild_id})
  end

  def refresh_all(guild_ids) do
    GenServer.cast(__MODULE__, {:refresh_all, guild_ids})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:refresh, guild_id}, state) do
    new_state = Map.put(state, guild_id, fetch_guild_commands(guild_id))

    {:noreply, new_state}
  end

  def handle_cast({:refresh_all, guild_ids}, _state) do
    new_state =
      Map.new(guild_ids, fn gid ->
        {gid, fetch_guild_commands(gid)}
      end)

    {:noreply, new_state}
  end

  def handle_call({:get_id, guild_id, name}, _from, state) do
    id =
      state
      |> Map.get(guild_id, %{})
      |> Map.get(name)

    {:reply, id, state}
  end

  defp get_id(guild_id, name) do
    GenServer.call(__MODULE__, {:get_id, guild_id, name})
  end

  defp fetch_guild_commands(guild_id) do
    case Nostrum.Api.ApplicationCommand.guild_commands(guild_id) do
      {:ok, commands} ->
        Map.new(commands, fn cmd ->
          {cmd.name, cmd.id}
        end)

      _ ->
        %{}
    end
  end
end
