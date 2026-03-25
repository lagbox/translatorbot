defmodule Bot.Core.Main do
  use Application

  def start(_type, _args) do
    children = [
      Nosedrum.Storage.Dispatcher,
      Bot.Core.CommandHandler,
      Bot.Core.UserRepo
    ]

    options = [strategy: :one_for_one, name: Bot.Supervisor]
    Supervisor.start_link(children, options)
  end
end
