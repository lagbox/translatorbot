defmodule Bot.Commands.ReactionRouter do
  @handlers [
    Bot.Commands.Reaction.Delete,
    Bot.Commands.Reaction.PinMessage,
    Bot.Commands.Reaction.Translate
  ]

  def handle(reaction) do
    Enum.each(@handlers, fn mod ->
      if function_exported?(mod, :match?, 1) and mod.match?(reaction) do
        mod.handle(reaction)
      end
    end)
  end
end
