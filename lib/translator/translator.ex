defmodule Translator do
  @languages Translator.API.get_languages()
             |> elem(1)
             |> Enum.map(fn x -> {x["code"], x["name"]} end)
             |> Enum.into(%{})

  def invertlangs do
    @languages
    |> Map.new(fn {k, v} -> {v, k} end)
  end

  def get_languages, do: @languages

  def language_by_code(code) do
    # Enum.find()
  end

  def translate(message, target) do
    Translator.API.get_translation(message, target)
  end
end
