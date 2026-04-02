defmodule Bot.Core.DiscordUser do
  alias Nostrum.Cache.UserCache
  alias Nostrum.Api.User

  def fetch(user_id) when is_integer(user_id) do
    case UserCache.get(user_id) do
      {:ok, user} -> user
      _ -> fetch_from_api(user_id)
    end
  end

  def display_name(user_id) when is_integer(user_id) do
    user_id
    |> fetch()
    |> display_name()
  end

  def display_name(%{global_name: name}) when is_binary(name), do: name
  def display_name(%{username: username}) when is_binary(username), do: username
  def display_name(_), do: "Unknown"

  defp fetch_from_api(user_id) do
    case User.get(user_id) do
      {:ok, user} -> user
      _ -> nil
    end
  end
end
