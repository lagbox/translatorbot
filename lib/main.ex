defmodule Application.Main do
  use Application

  def start(_type, _args) do
    init_mnesia()

    Translator.Cache.TranslationCache.init()

    children = [
      Bot.Core.CommandHandler,
      Nosedrum.Storage.Dispatcher,
      Translator.Languages,
      Translator.System.Cooldown,
      Translator.System.MessageLifecycle
    ]

    options = [strategy: :one_for_one, name: Bot.Supervisor]
    Supervisor.start_link(children, options)
  end

  defp init_mnesia do
    :mnesia.stop()

    case :mnesia.create_schema([node()]) do
      :ok -> :ok
      {:error, {:already_exists, _}} -> :ok
      _ -> :ok
    end

    :mnesia.start()

    Translator.Persistence.UserPrefsMnesia.init()

    :mnesia.wait_for_tables([:user_langs], 5_000)
  end
end
