defmodule Bot.Commands.ReactionRouter do
  @handlers [
    Bot.Commands.Reaction.Delete,
    Bot.Commands.Reaction.Pin,
    Bot.Commands.Reaction.Translate
  ]

  def handle(reaction) do
    # Enum.each(@handlers, fn mod ->
    # 1 handler per reaction
    Enum.find_value(@handlers, fn mod ->
      if function_exported?(mod, :match?, 1) and mod.match?(reaction) do
        mod.handle(reaction)
        # 1 handler per reaction
        true
      end
    end) || :ignore
  end
end
