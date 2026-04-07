defmodule Bot.Commands.Interactions.DeleteMessage do
  alias Nostrum.Api.Message

  def handle(interaction, user_id) do
    if Integer.to_string(interaction.user.id) == user_id do
      Message.delete(interaction.channel_id, interaction.message.id)
    end
  end
end
