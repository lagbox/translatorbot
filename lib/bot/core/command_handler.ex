defmodule Bot.Core.CommandHandler do
  use Nostrum.Consumer
  require Logger

  alias Bot.Commands.AutocompleteRouter
  alias Bot.Commands.InteractionRouter
  alias Bot.Core.ApplicationCommandLoader
  alias Nosedrum.Storage.Dispatcher

  def handle_event({:READY, _, _}), do: ApplicationCommandLoader.load_all()

  def handle_event({:INTERACTION_CREATE, interaction, _}) do
    case interaction.type do
      # Autocomplete
      4 -> AutocompleteRouter.handle_interaction(interaction)
      # Message Component
      3 -> InteractionRouter.handle_interaction(interaction)
      # Application Command, Ping, Modal Submit
      # Nosedrum Handler
      _ -> Dispatcher.handle_interaction(interaction)
    end
  end

  def handle_event({:MESSAGE_REACTION_ADD, reaction, _ws}) do
    Bot.Commands.ReactionRouter.handle(reaction)
  end

  def handle_event(_), do: :noop
end
