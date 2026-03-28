defmodule Translator do
  def invertlangs do
    Translator.Languages.get()
    |> Map.new(fn {k, v} -> {v, k} end)
  end

  def get_languages, do: Translator.Languages.get()

  def language_by_code(code) do
    Translator.Languages.get(code)
  end

  def translate(message, target) do
    Translator.API.get_translation(message, target)
  end
end
