defmodule Bot.Commands.Reaction.Delete do
  @emoji "❌"

  def match?(%{emoji: %{name: @emoji}}), do: true
  def match?(_), do: false

  def handle(_reaction) do
    # Bot.Commands.ReactionTranslation.handle_delete_reaction(reaction)
  end
end
