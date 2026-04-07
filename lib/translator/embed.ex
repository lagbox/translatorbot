defmodule Translator.Embed do
  alias Translator.Languages
  alias Bot.Core.DiscordUser
  # alias Translator.Language.Flags

  @color 0x5865F2

  def translation(message, %{translated: t, detected: s}, target, user, emoji \\ nil) do
    # flags = Flags.flags_for(target)

    footer =
      case emoji do
        nil ->
          %{}

        _ ->
          %{
            text: "#{DiscordUser.display_name(user)} → #{emoji}",
            icon_url: avatar_url(user)
          }
      end

    %{
      color: @color,
      description:
        "#{Languages.get(s)} ➤ #{Languages.get(target)}\n" <>
          "> #{t}",
      footer: footer,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  def error(title, description) do
    %{
      color: 0xC01C28,
      title: title,
      description: description
    }
  end

  defp avatar_url(user),
    do: "https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar}.png"

  defp truncate(text, max),
    do: if(String.length(text) > max, do: String.slice(text, 0, max) <> "...", else: text)
end
