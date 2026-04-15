defmodule Bot.Commands.Reaction.Delete do
  @behaviour Bot.Commands.Reaction.Handler

  alias Translator.System.MessageLifecycle

  @emoji "🗑️"

  def match?(%{emoji: %{name: @emoji}}), do: true
  def match?(_), do: false

  def handle(reaction) do
    MessageLifecycle.delete_if_owner(reaction.message_id, reaction.user_id)
  end
end
