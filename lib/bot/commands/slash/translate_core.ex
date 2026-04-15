defmodule Bot.Commands.Slash.TranslateCore do
  alias Bot.Presentation.TranslationEmbed
  alias Translator.Persistence.UserPrefsMnesia

  def command(interaction, opts \\ []) do
    ephemeral? = Keyword.get(opts, :ephemeral?, false)

    optsm = opts_map(interaction)
    text = optsm["text"]
    target = optsm["target"]
    source = optsm["source"] || "auto"

    user_id = interaction.user.id

    UserPrefsMnesia.bump_usage(user_id, target)

    case Translator.translate(text, target, source: source) do
      {:error, _} ->
        [
          content: "❌ Translation failed",
          ephemeral?: true
        ]

      {:ok, result} ->
        [
          embeds: [
            TranslationEmbed.build(result, target, interaction.user)
          ],
          ephemeral?: ephemeral?
        ]
    end
  end

  def options do
    [
      %{
        type: :string,
        name: "text",
        required: true,
        description: "Text to translate"
      },
      %{
        type: :string,
        name: "target",
        description: "Target language",
        required: true,
        autocomplete: true
      },
      %{
        type: :string,
        name: "source",
        description: "Source language",
        required: false,
        autocomplete: true
      }
    ]
  end

  defp opts_map(interaction) do
    interaction.data.options
    |> Kernel.||([])
    |> Map.new(&{&1.name, &1.value})
  end
end
