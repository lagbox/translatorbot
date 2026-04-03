defmodule Translator do
  alias Translator.{
    Cache.TranslationCache,
    Languages,
    LibreTranslate
  }

  @default_source "auto"

  def invertlangs do
    get_languages()
    |> Map.new(fn {k, v} -> {v, k} end)
  end

  def get_languages, do: Languages.get()

  def language_by_code(code) do
    Languages.get(code)
  end

  def translate(text, target, opts \\ []) do
    source = Keyword.get(opts, :source, @default_source)
    cache_key = {text, target, source}

    case TranslationCache.get(cache_key) do
      nil ->
        case LibreTranslate.translate(text, target, source: source) do
          {:ok, result} ->
            TranslationCache.put(cache_key, result)
            {:ok, result}

          error ->
            error
        end

      cached ->
        {:ok, cached}
    end
  end
end
