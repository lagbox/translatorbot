defmodule Bot.Commands.Reaction.PinMessage do
  @behaviour Bot.Commands.Reaction.Handler

  @emoji "📌"

  def match?(%{emoji: %{name: @emoji}}), do: true
  def match?(_), do: false

  def handle(reaction) do
    # only messages created by bot
    Translator.System.MessageLifecycle.cancel_delete(reaction.message_id)
    # leave pushpin emoji or remove
    #   if we remove it, update the message to say it has been pinned?
    #     provide the user with how they can remove the message
  end
end
