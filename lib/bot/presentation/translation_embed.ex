defmodule Bot.Presentation.TranslationEmbed do
  alias Translator.Languages
  alias Bot.Core.DiscordUser

  @embed_color 0x5865F2

  def build(%{translated: translated, detected: source}, target, user, opts \\ []) do
    opts = Keyword.merge([emoji: "Command"], opts)
    emoji = opts[:emoji]

    %{
      color: @embed_color,
      description: "#{Languages.get(source)} ➤ #{Languages.get(target)}\n> *#{translated}*",
      footer: %{
        text: "#{DiscordUser.display_name(user)} → #{emoji}",
        icon_url: avatar_url(user)
      },
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  def components(_user_id, _lang) do
    []
  end

  def error(title, description) do
    %{
      color: 0xC01C28,
      title: title,
      description: description
    }
  end

  defp avatar_url(user) do
    "https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar}.png"
  end
end
