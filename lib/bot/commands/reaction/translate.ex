defmodule Bot.Commands.Reaction.Translate do
  alias Translator.LanguageFlags

  def match?(%{emoji: %{name: emoji}}) do
    LanguageFlags.codes_for_flag(emoji) != []
  end

  def match?(_), do: false

  def handle(reaction) do
    Bot.Commands.ReactionTranslation.handle_reaction(reaction)
  end
end
