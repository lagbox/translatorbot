defmodule Translator.API do
  alias Translator.HTTPClient

  def languages() do
    HTTPClient.new()
    |> HTTPClient.get("languages")
  end

  def translate(message, target, ""), do: translate(message, target)
  def translate(message, target, nil), do: translate(message, target)

  def translate(message, target, source) do
    data = %{
      q: message,
      target: target,
      source: source
    }

    HTTPClient.new()
    |> HTTPClient.post("translate", data)
  end

  def translate(message, target), do: translate(message, target, "auto")
end
