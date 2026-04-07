defmodule Bot.Commands.Reaction.Translate do
  @behaviour Bot.Commands.Reaction.Handler

  alias Bot.Translation.Orchestrator
  alias Translator.Language.Flags

  def match?(%{emoji: %{name: emoji}}) do
    Flags.is_flag?(emoji) &&
      Flags.codes_for_flag(emoji) != []
  end

  def match?(_), do: false

  def handle(%{emoji: %{name: emoji}} = reaction) do
    case Flags.primary_language(emoji) do
      {:ok, lang} ->
        Orchestrator.translate_from_reaction(reaction, lang)

      :error ->
        :ignore
    end
  end
end
