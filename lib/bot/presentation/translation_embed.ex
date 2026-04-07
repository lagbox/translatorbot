defmodule Bot.Presentation.TranslationEmbed do
  alias Translator.Languages
  alias Bot.Core.DiscordUser

  @embed_color 0x5865F2

  def build(_message, %{translated: t, detected: s}, target, user, emoji) do
    %{
      color: @embed_color,
      description: "#{Languages.get(s)} ➤ #{Languages.get(target)}\n> #{t}",
      footer: %{
        text: "#{DiscordUser.display_name(user)} → #{emoji}",
        icon_url: avatar_url(user)
      },
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  def components(user_id, _lang) do
    [
      %{
        type: 1,
        components: [
          %{
            type: 2,
            style: 4,
            label: "Delete",
            custom_id: "delete:#{user_id}"
          },
          %{
            type: 2,
            style: 1,
            label: "Pin",
            custom_id: "pin:#{user_id}"
          }
        ]
      }
    ]
  end

  defp avatar_url(user) do
    "https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar}.png"
  end
end
