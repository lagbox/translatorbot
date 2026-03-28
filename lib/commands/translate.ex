defmodule Bot.Commands.Translate do
  @behaviour Nosedrum.ApplicationCommand

  alias Bot.Core.UserRepo
  alias Nostrum.Struct.Embed

  def name(), do: "translate"

  @impl true
  def description() do
    "Translates a message."
  end

  @impl true
  def command(interaction) do
    discord_user = interaction.user
    [{_id, %{content: message}}] = Map.to_list(interaction.data.resolved.messages)

    embed =
      case UserRepo.get(discord_user.id) do
        nil ->
          %Embed{}
          |> Embed.put_color(0xC01C28)
          |> Embed.put_title("Your language has not been set yet.")
          |> Embed.put_description("Please use the `/set_language` command to set your language.")

        user ->
          {:ok,
           %{
             "translatedText" => translated,
             "detectedLanguage" => %{"language" => source}
           }} = Translator.translate(message, user.language)

          sourcefull = Translator.Languages.get(source)
          userfull = Translator.Languages.get(user.language)

          %Embed{}
          |> Embed.put_color(0x3498DB)
          |> Embed.put_description(
            "> #{translated}\nFrom #{sourcefull} (#{String.upcase(source)}) To #{userfull} (#{String.upcase(user.language)})"
          )

          # |> Embed.put_title(translated)
          # |> Embed.put_field("Something", "something", true)
          # |> Embed.put_footer("💬")
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
