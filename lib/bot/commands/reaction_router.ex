defmodule Bot.Commands.ReactionRouter do
  @handlers [
    Bot.Commands.Reaction.Translate
    # Bot.Commands.Reactions.Delete
  ]

  def handle(reaction) do
    Enum.each(@handlers, fn mod ->
      if function_exported?(mod, :match?, 1) and mod.match?(reaction) do
        mod.handle(reaction)
      end
    end)
  end
end
