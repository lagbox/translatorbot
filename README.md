# TranslatorBot

Discord Translation bot written in Elixir with libretranslate (python) for translation support.


## Requirements

### Libretranslate

You will need to get libretranslate setup and running. This will take HTTP requests for the languages supported and to do the translations.

### Elixir

This was built using Elxir 1.19.5 but should work with older versions.

### Env

You will need a `DISCORD_TOKEN` variable set with your Discord token.

## Feature List

* Set a default language with the bot using `/set_language` (persisted)
* Translate any message from the Message context menu
* Translate any message with a flag reaction (will remove flag after translation)
* Remove translation with a delete button
* Translate any message from supported source language to supported target language
* All commands language selection is autocomplete(weighted by popularity and user personal usage)


## Coming Soon

More information, setup, etc etc.
