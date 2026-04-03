defmodule Bot.Commands.Autocomplete.Languages do
  alias Translator.Language.Search
  alias Bot.Commands.Autocomplete.Helpers

  def handle(interaction) do
    options = interaction.data.options || []
    query = Helpers.get_query(options)

    user_id = interaction.user.id
    languages = Translator.get_languages()

    languages =
      Enum.map(
        languages,
        fn {k, v} -> %{"name" => v, "code" => k} end
      )

    choices = Search.search(languages, query, user_id)

    Nostrum.Api.create_interaction_response(interaction, %{
      type: 8,
      data: %{choices: choices}
    })
  end
end
