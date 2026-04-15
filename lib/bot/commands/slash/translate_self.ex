defmodule Bot.Commands.Slash.TranslateSelf do
  @behaviour Nosedrum.ApplicationCommand

  alias Bot.Commands.Slash.TranslateCore

  @impl true
  def type(), do: :slash

  def name(), do: "translate_self"

  @impl true
  def description, do: "Translates the given text into a HIDDEN message."

  @impl true
  def options, do: TranslateCore.options()

  @impl true
  def command(interaction), do: TranslateCore.command(interaction, ephemeral?: true)
end
