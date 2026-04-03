defmodule Bot.Commands.ReactionTranslation do
  require Logger

  alias Bot.Core.DiscordUser
  alias Nostrum.Api.Message

  alias Translator.{
    Embed,
    Language.Flags,
    Languages,
    Persistence.UserPrefsMnesia,
    System.Cooldown,
    System.MessageLifecycle
  }

  @embed_color 0x5865F2

  def handle_reaction(%{emoji: %{name: emoji}} = reaction) do
    user_id = reaction.user_id

    if user_id != Nostrum.Cache.Me.get().id do
      case Flags.codes_for_flag(emoji) do
        [] ->
          :ignore

        [lang | _] ->
          translate_and_reply(user_id, reaction, lang)
      end
    end
  end

  def handle_interaction(%{data: %{custom_id: id}} = interaction) do
    case String.split(id, ":") do
      ["delete", user_id] ->
        if Integer.to_string(interaction.user.id) == user_id do
          Message.delete(interaction.channel_id, interaction.message.id)
        end

      _ ->
        :ignore
    end
  end

  defp translate_and_reply(user_id, reaction, target_lang) do
    with true <- Cooldown.allow?(reaction.message_id, target_lang),
         {:ok, message} <-
           Message.get(reaction.channel_id, reaction.message_id),
         true <- String.trim(message.content) != "" do
      lang = target_lang
      user = DiscordUser.fetch(user_id)

      case Translator.translate(message.content, lang) do
        {:ok, result} ->
          UserPrefsMnesia.bump_usage(user_id, lang)

          case send_translation(reaction, message, result, lang, user) do
            {:ok, reply} ->
              remove_user_reaction(reaction)
              auto_delete(reply)

            _ ->
              :ignore
          end

        _ ->
          error(reaction)
      end
    else
      _ -> :ignore
    end
  end

  defp auto_delete(message) do
    MessageLifecycle.schedule_delete(message)
  end

  defp send_translation(reaction, message, %{translated: t, detected: s} = result, lang, user) do
    UserPrefsMnesia.bump_usage(user.id, lang)

    embed = build_embed(message, t, s, lang, user, reaction.emoji.name)

    # embed =
    #   # Embed.translation(
    #   #   message,
    #   #   result,
    #   #   lang,
    #   #   user,
    #   #   reaction.emoji.name
    #   # )

    Message.create(
      reaction.channel_id,
      embeds: [embed],
      components: components(user.id, lang),
      message_reference: %{message_id: reaction.message_id},
      allowed_mentions: :none
    )
  end

  def remove_user_reaction(%Nostrum.Struct.Event.MessageReactionAdd{
        channel_id: channel_id,
        message_id: message_id,
        emoji: %{name: name},
        user_id: user_id
      }) do
    Task.start(fn ->
      emoji_str = URI.encode(name, &URI.char_unreserved?/1)

      case Nostrum.Api.Message.delete_user_reaction(
             channel_id,
             message_id,
             emoji_str,
             user_id
           ) do
        {:ok} ->
          :ok

        {:error, reason} ->
          Logger.warning("Failed to remove reaction #{name} from #{user_id}: #{inspect(reason)}")
      end
    end)
  end

  defp components(user_id, _lang) do
    [
      %{
        type: 1,
        components: [
          %{
            type: 2,
            style: 4,
            label: "Delete",
            custom_id: "delete:#{user_id}"
          }
        ]
      }
    ]
  end

  defp build_embed(_message, translated, source, target, user, emoji) do
    %{
      color: @embed_color,
      description:
        "#{Languages.get(source)} ➤ #{Languages.get(target)}\n" <>
          "> " <>
          translated,
      footer: %{
        text: "#{DiscordUser.display_name(user)} → #{emoji}",
        icon_url: avatar_url(user)
      },
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  defp avatar_url(user) do
    "https://cdn.discordapp.com/avatars/#{user.id}/#{user.avatar}.png"
  end

  # defp truncate(text, max),
  #   do: if(String.length(text) > max, do: String.slice(text, 0, max) <> "...", else: text)

  defp error(reaction) do
    Message.create(reaction.channel_id, content: "❌ Translation failed.")
  end
end
