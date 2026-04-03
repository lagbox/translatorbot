defmodule Bot.Commands.Message.Translate do
  @behaviour Nosedrum.ApplicationCommand

  alias Translator.Persistence.UserPrefsMnesia
  alias Translator.Embed

  def name(), do: "Translate Message"

  @impl true
  def description() do
    "Translates a message."
  end

  @impl true
  def command(interaction) do
    discord_user = interaction.user
    [{_id, %{content: message}}] = Map.to_list(interaction.data.resolved.messages)

    embed =
      case UserPrefsMnesia.get_preferred(discord_user.id) do
        nil ->
          Embed.error(
            "Your language has not been set yet.",
            "Please use the `/set_language` command to set your language."
          )

        language ->
          {:ok, resp} = Translator.translate(message, language)

          Embed.translation(message, resp, language, discord_user)
      end

    [
      ephemeral?: true,
      embeds: [embed]
    ]
  end

  @impl true
  def type() do
    :message
  end

  @impl true
  def options() do
    [
      %{
        type: :string,
        name: "message",
        description: "The message to be translated.",
        required: true
      }
    ]
  end
end
