defmodule Bot.Commands.SetLanguage do
  @behaviour Nosedrum.ApplicationCommand

  alias Bot.Core.UserRepo
  alias Nostrum.Struct.Embed

  def name(), do: "set_language"

  @impl true
  def description() do
    "Set your default language."
  end

  @impl true
  def command(interaction) do
    %Nostrum.Struct.Interaction{user: user} = interaction
    [%{name: "language", value: lang}] = interaction.data.options

    UserRepo.put(
      user.id,
      user
      |> UserRepo.from_discord_user()
      |> UserRepo.add_language(lang)
    )

    langfull = Map.get(Translator.get_languages(), lang)
    content = "Your language has been set to #{langfull} (#{String.upcase(lang)})."

    embed =
      %Embed{}
      |> Embed.put_color(0x2EC27E)
      |> Embed.put_title(content)

    [
      embeds: [embed],
      ephemeral?: true
    ]
  end

  @impl true
  def type() do
    :slash
  end

  @impl true
  def options() do
    [
      %{
        type: :string,
        name: "language",
        description: "The language to set.",
        required: true,
        autocomplete: true
      }
    ]
  end
end
