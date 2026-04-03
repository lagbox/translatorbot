defmodule Bot.Commands.Slash.SetLanguage do
  @behaviour Nosedrum.ApplicationCommand

  alias Nostrum.Struct.{Embed, Interaction}
  alias Translator.{Languages, Persistence.UserPrefsMnesia}

  def name(), do: "set_language"

  @impl true
  def description() do
    "Set your default language."
  end

  @impl true
  def command(interaction) do
    %Interaction{user: user} = interaction
    [%{name: "language", value: lang}] = interaction.data.options

    # replace with some better validation system
    embed =
      case Languages.get(lang) do
        nil -> do_bad_language(lang)
        langfull -> do_set_language(user, lang, langfull)
      end

    [
      embeds: [embed],
      ephemeral?: true
    ]
  end

  defp do_bad_language(lang) do
    %Embed{}
    |> Embed.put_color(0xC01C28)
    |> Embed.put_title("\"#{lang}\" is not an available language option. Please try again.")
  end

  defp do_set_language(user, lang, langfull) do
    UserPrefsMnesia.set_preferred(user.id, lang)

    %Embed{}
    |> Embed.put_color(0x2EC27E)
    |> Embed.put_title("Your language has been successfully set.")
    |> Embed.put_description("Your language is set to **#{langfull} (#{String.upcase(lang)})**.")
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
