defmodule Bot.Commands.Reaction.Pin do
  @behaviour Bot.Commands.Reaction.Handler

  @emoji "📌"

  def match?(%{emoji: %{name: @emoji}}), do: true
  def match?(_), do: false

  def handle(reaction) do
    Translator.System.MessageLifecycle.pin(reaction.message_id)
  end
end
