defmodule Bot.Translation.Orchestrator do
  require Logger

  alias Nostrum.Api.Message
  alias Bot.Core.DiscordUser

  alias Translator.{
    System.Cooldown,
    System.MessageLifecycle,
    Persistence.UserPrefsMnesia
  }

  alias Bot.Presentation.TranslationEmbed

  def translate_from_reaction(reaction, target_lang) do
    user_id = reaction.user_id

    with true <- not_self?(user_id),
         true <- Cooldown.allow?(reaction.message_id, target_lang),
         {:ok, message} <- Message.get(reaction.channel_id, reaction.message_id),
         true <- valid_message?(message),
         {:ok, result} <- Translator.translate(message.content, target_lang) do
      user = DiscordUser.fetch(user_id)
      UserPrefsMnesia.bump_usage(user_id, target_lang)

      case send_translation(reaction, result, target_lang, user) do
        {:ok, reply} ->
          MessageLifecycle.schedule_delete(reply, user_id)
          remove_user_reaction(reaction)

        {:error, _} ->
          error(reaction)
      end
    else
      _ -> :ignore
    end
  end

  defp not_self?(user_id), do: user_id != Nostrum.Cache.Me.get().id

  defp valid_message?(message), do: String.trim(message.content) != ""

  defp send_translation(reaction, result, lang, user) do
    embed = TranslationEmbed.build(result, lang, user, emoji: reaction.emoji.name)

    Message.create(
      reaction.channel_id,
      embeds: [embed],
      components: TranslationEmbed.components(user.id, lang),
      message_reference: %{message_id: reaction.message_id},
      allowed_mentions: :none
    )
  end

  defp remove_user_reaction(reaction) do
    Task.start(fn ->
      emoji = URI.encode(reaction.emoji.name, &URI.char_unreserved?/1)

      case Message.delete_user_reaction(
             reaction.channel_id,
             reaction.message_id,
             emoji,
             reaction.user_id
           ) do
        {:ok} ->
          :ok

        {:error, reason} ->
          Logger.warning("Failed to remove reaction: #{inspect(reason)}")
      end
    end)
  end

  defp error(reaction) do
    Message.create(
      reaction.channel_id,
      content: "❌ Translation failed.",
      message_reference: %{message_id: reaction.message_id}
    )
  end
end
