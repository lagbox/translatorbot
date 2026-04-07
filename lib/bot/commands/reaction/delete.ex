defmodule Bot.Commands.Reaction.Delete do
  @behaviour Bot.Commands.Reaction.Handler

  @emoji "❌"

  def match?(%{emoji: %{name: @emoji}}), do: true
  def match?(_), do: false

  def handle(_reaction) do
    # only message created by bot
    #   only the person who caused the interaction can delete

    # Bot.Commands.ReactionTranslation.handle_delete_reaction(reaction)
  end
end
