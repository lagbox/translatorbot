defmodule Bot.Commands.InteractionRouter do
  require Logger

  alias Bot.Commands.Interactions.DeleteMessage
  # alias Translator.System.MessageLifecycle

  def handle_interaction(%{data: %{custom_id: id}} = interaction) do
    case String.split(id, ":") do
      ["delete", user_id] ->
        DeleteMessage.handle(interaction, user_id)

      # ["pin", _] ->
      #   MessageLifecycle.cancel_delete(interaction.message.id)

      _ ->
        :ignore
    end
  end
end
