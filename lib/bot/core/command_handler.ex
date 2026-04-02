defmodule Bot.Core.CommandHandler do
  use Nostrum.Consumer
  require Logger

  alias Bot.Core.ApplicationCommandLoader
  alias Nosedrum.Storage.Dispatcher
  alias Bot.Commands.AutocompleteRouter

  def handle_event({:READY, _, _}), do: ApplicationCommandLoader.load_all()

  def handle_event({:INTERACTION_CREATE, interaction, _}) do
    case interaction.type do
      4 -> AutocompleteRouter.handle(interaction)
      3 -> Bot.Commands.ReactionTranslation.handle_interaction(interaction)
      _ -> Dispatcher.handle_interaction(interaction)
    end
  end

  def handle_event({:MESSAGE_REACTION_ADD, reaction, _ws}) do
    Bot.Commands.ReactionRouter.handle(reaction)
  end

  def handle_event(_), do: :noop
end
