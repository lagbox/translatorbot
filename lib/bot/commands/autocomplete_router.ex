defmodule Bot.Commands.AutocompleteRouter do
  alias Bot.Commands.Autocomplete.Languages

  @routes %{
    "Translate Message" => Languages,
    "translate" => Languages,
    "set_language" => Languages
  }

  def handle_interaction(interaction) do
    command = interaction.data.name

    case Map.get(@routes, command) do
      nil -> empty_response(interaction)
      module -> module.handle(interaction)
    end
  end

  defp empty_response(interaction) do
    Nostrum.Api.create_interaction_response(interaction, %{
      type: 8,
      data: %{choices: []}
    })
  end
end
