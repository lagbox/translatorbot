defmodule Bot.Reactions.Translation do
  require Logger

  alias Nostrum.Api.Message
  alias Translator

  alias Translator.{
    Embed,
    Language.Flags,
    Persistence.UserPrefsMnesia,
    System.Cooldown
  }

  def handle(reaction) do
    with true <- allowed?(reaction),
         [lang | _] <- Flags.codes_for_flag(reaction.emoji.name),
         {:ok, message} <- Message.get(reaction.channel_id, reaction.message_id),
         true <- message.content != "",
         true <- Cooldown.allow?(reaction.message_id, lang),
         {:ok, result} <- Translator.translate(message.content, lang) do
      UserPrefsMnesia.bump_usage(reaction.user_id, lang)

      {:ok, reply} =
        Message.create(
          reaction.channel_id,
          embeds: [Embed.translation(message, result, lang, reaction)],
          components: components(reaction.user_id),
          message_reference: %{message_id: reaction.mesage_id},
          allowed_mentions: :none
        )

      remove_reaction(reaction)
      auto_delete(reply)

      {:ok, reply}
    else
      _ -> :ignore
    end
  end

  defp allowed?(reaction) do
    reaction.user_id != Nostrum.Cache.Me.get().id
  end

  defp auto_delete(message) do
    Task.start(fn ->
      Process.sleep(60_000)
      Message.delete(message.channel_id, message.id)
    end)
  end

  defp components(user_id) do
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

  def remove_reaction(%Nostrum.Struct.Event.MessageReactionAdd{
        channel_id: channel_id,
        message_id: message_id,
        emoji: %{name: name},
        user_id: user_id
      }) do
    Task.start(fn ->
      emoji_str = URI.encode(name, &URI.char_unreserved?/1)

      case Message.delete_user_reaction(
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
end
