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

    case Translator.Languages.get(lang) do
      nil -> do_bad_language(lang)
      langfull -> do_set_language(user, lang, langfull)
    end
  end

  defp do_bad_language(lang) do
    embed =
      %Embed{}
      |> Embed.put_color(0xC01C28)
      |> Embed.put_title("\"#{lang}\" is not an available language option. Please try again.")

    [
      embeds: [embed],
      ephemeral?: true
    ]
  end

  defp do_set_language(user, lang, langfull) do
    UserRepo.put(
      user.id,
      user
      |> UserRepo.from_discord_user()
      |> UserRepo.add_language(lang)
    )

    embed =
      %Embed{}
      |> Embed.put_color(0x2EC27E)
      |> Embed.put_title("Your language has been successfully set.")
      |> Embed.put_description(
        "Your language is set to **#{langfull} (#{String.upcase(lang)})**."
      )

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
