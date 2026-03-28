defmodule Bot.Core.CommandHandler do
  use Nostrum.Consumer
  require Logger

  alias Bot.Core.ApplicationCommandLoader
  alias Nosedrum.Storage.Dispatcher

  def handle_event({:READY, _, _}), do: ApplicationCommandLoader.load_all()
  # def handle_event({:INTERACTION_CREATE, intr, _}), do: Dispatcher.handle_interaction(intr)
  def handle_event({:INTERACTION_CREATE, interaction, _}) do
    case interaction.type do
      4 -> handle_autocomplete(interaction)
      2 -> Dispatcher.handle_interaction(interaction)
      _ -> :ignore
    end
  end

  def handle_event(_), do: :noop

  def handle_autocomplete(interaction) do
    focused_option =
      interaction.data.options
      |> Enum.find(& &1.focused)

    query = focused_option.value || ""

    Nostrum.Api.create_interaction_response(interaction, %{
      type: 8,
      data: %{choices: get_language_choices(query)}
    })
  end

  def get_language_choices(query) do
    Translator.get_languages()
    |> Enum.map(fn {k, v} -> %{name: v, value: k} end)
    |> Enum.filter(&String.contains?(String.downcase(&1.name), String.downcase(query)))
    |> Enum.take(25)

    # if we end up with no results
    #   search against the code to find results
    #   ex: es -> Spanish
  end
end
