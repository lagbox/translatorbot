defmodule Bot.Commands.Slash.Ping do
  require Logger
  @behaviour Nosedrum.ApplicationCommand

  def name(), do: "ping"

  @impl true
  def description(), do: "Hello? Is there anybody in there?"

  @impl true
  def command(_interaction), do: [content: "**🏓** ... pong!"]

  @impl true
  def type(), do: :slash
end
