defmodule Bot.Commands.Slash.Translate do
  @behaviour Nosedrum.ApplicationCommand

  alias Translator.Persistence.UserPrefsMnesia

  @impl true
  def type(), do: :slash

  def name(), do: "translate"

  @impl true
  def description, do: "Translate the given text"

  @impl true
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

  @impl true
  def command(interaction) do
    opts = interaction.data.options || []

    text = get_opt(opts, "text")
    target = get_opt(opts, "target")
    source = get_opt(opts, "source") || "auto"

    user_id = interaction.user.id

    # UserPrefsMnesia.bump_usage(user_id, source)
    UserPrefsMnesia.bump_usage(user_id, target)

    case Translator.translate(text, target, source: source) do
      {:error, _} ->
        [
          content: "❌ Translation failed",
          ephemeral?: true
        ]

      {:ok, result} ->
        [
          content: "🌐 **#{source} → #{target}**\n> #{result.translated}"
        ]
    end
  end

  defp get_opt(options, name) do
    case Enum.find(options, &(&1.name == name)) do
      nil -> nil
      opt -> opt.value
    end
  end
end
