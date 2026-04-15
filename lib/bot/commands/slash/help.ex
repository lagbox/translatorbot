defmodule Bot.Commands.Slash.Help do
  @behaviour Nosedrum.ApplicationCommand

  alias Bot.Commands.Registry

  def name(), do: "help"

  @impl true
  def type(), do: :slash

  @impl true
  def description(), do: "Some useful and helpful informaiton."

  @impl true
  def command(%{guild_id: guild_id} = _interaction) do
    botname = Nostrum.Cache.Me.get().username
    mention = &Registry.mention(guild_id, &1)

    content =
      String.trim_leading("""
      This bot can do translations to and from 98 different languages.
      You can get translations in 3 different ways:
      1. Message Context Menu Command
        * When you bring up the context menu for a message you will see a "Apps >" option. Under that you will see "Apps" > "#{botname}" > "Translate Message"
      1. Slash Commands
        * You can use the #{mention.("translate")} & #{mention.("translate_self")} commands to get arbitrary translations.
      1. Country Flag Emoji Reaction
        * You can react to a message with a country flag emoji (🇪🇸) to get a translation to the corresponding language. These translation messages will will **automatically** be **removed** after **1 minute**.
        * You can react to these translation message with the following emojis:
            - 📌 - cancel the autodelete ("pin" the message)
            - 🗑️ - delete a "pinned" message (when you are the owner)
      ### Slash Commands
      **Preference**
      #{mention.("set_language")} - Tell the bot your default language preference.
      **Translate**
      #{mention.("translate")} | #{mention.("translate_self")} - Translate arbitrary text to and from languages.
      **Fun**
      #{mention.("8ball")} - What will the wise magic 8ball have to say?
      #{mention.("ping")} - Is #{botname} even there?
      """)

    [
      embeds: [
        %{
          title: "Help Menu",
          description: content
        }
      ],
      ephemeral?: true
    ]
  end
end
