defmodule Bot.Commands.Reaction.Translate do
  alias Translator.Language.Flags

  def match?(%{emoji: %{name: emoji}}) do
    Flags.is_flag?(emoji) &&
      Flags.codes_for_flag(emoji) != []
  end

  def match?(_), do: false

  def handle(reaction) do
    Bot.Commands.ReactionTranslation.handle_reaction(reaction)
  end
end
