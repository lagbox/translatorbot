defmodule Translator.TranslationCache do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get(text, lang) do
    GenServer.call(__MODULE__, {:get, text, lang})
  end

  def put(text, lang, result) do
    GenServer.cast(__MODULE__, {:put, text, lang, result})
  end

  def init(state), do: {:ok, state}

  def handle_call({:get, text, lang}, _from, state) do
    {:reply, Map.get(state, {text, lang}), state}
  end

  def handle_cast({:put, text, lang, result}, state) do
    {:noreply, Map.put(state, {text, lang}, result)}
  end
end
