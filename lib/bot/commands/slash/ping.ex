defmodule Bot.Commands.Slash.Ping do
  require Logger
  @behaviour Nosedrum.ApplicationCommand

  def name(), do: "ping"

  @impl true
  def description(), do: "Hello? Is there anybody in there?"

  @impl true
  def type(), do: :slash

  @impl true
  def command(interaction) do
    start_time = System.monotonic_time(:millisecond)

    #  defer
    Nostrum.Api.create_interaction_response(interaction, %{
      type: 5
    })

    api_latency = System.monotonic_time(:millisecond) - start_time
    uptime_ms = System.monotonic_time(:millisecond) - bot_start_time()
    uptime = format_uptime(uptime_ms)

    color =
      cond do
        # green
        api_latency < 100 -> 0x57F287
        # yellow
        api_latency < 250 -> 0xFEE75C
        # red
        true -> 0xED4245
      end

    Nostrum.Api.Interaction.edit_response(interaction, %{
      embeds: [
        %{
          title: "🏓 ... Pong!",
          color: color,
          fields: [
            %{
              name: "API Latency",
              value: "#{api_latency} ms",
              inline: true
            },
            %{
              name: "Uptime",
              value: uptime,
              inline: true
            }
          ],
          timestamp: DateTime.utc_now()
        }
      ]
    })

    []
  end

  defp bot_start_time do
    :persistent_term.get(:bot_start_time, System.monotonic_time(:millisecond))
  end

  defp format_uptime(ms) do
    total_seconds = div(ms, 1000)

    days = div(total_seconds, 86400)
    hours = div(rem(total_seconds, 86400), 3600)
    minutes = div(rem(total_seconds, 3600), 60)
    seconds = rem(total_seconds, 60)

    "#{days}d #{hours}h #{minutes}m #{seconds}s"
  end
end
