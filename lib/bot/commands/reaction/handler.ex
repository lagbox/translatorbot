defmodule Bot.Commands.Reaction.Handler do
  @callback match?(map()) :: boolean()
  @callback handle(map()) :: any()
end
