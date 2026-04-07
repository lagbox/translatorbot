defmodule Translator.Languages do
  use GenServer

  @key :translator_languages

  # @TODO: pull from config / env instead
  @refresh_interval :timer.hours(6)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    load_and_cache()
    schedule_refresh()
    ##
    {:ok, %{}}
  end

  @impl true
  def handle_info(:refresh, state) do
    load_and_cache()
    schedule_refresh()
    {:noreply, state}
  end

  @impl true
  def handle_cast(:refresh, state) do
    load_and_cache()
    {:noreply, state}
  end

  def get do
    case :persistent_term.get(@key, :not_loaded) do
      :not_loaded ->
        load_and_cache()
        :persistent_term.get(@key, %{})

      value ->
        value
    end
  end

  def get(code) do
    Map.get(get(), code)
  end

  def refresh do
    GenServer.cast(__MODULE__, :refresh)
  end

  defp load_and_cache do
    langs =
      case Translator.API.languages() do
        {:ok, langs} -> Enum.map(langs, fn x -> {x["code"], x["name"]} end)
        _ -> []
      end
      |> Enum.into(%{})

    case :persistent_term.get(@key, %{}) do
      # cool
      ^langs -> :ok
      _ -> :persistent_term.put(@key, langs)
    end
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_interval)
  end
end
