defmodule Translator.API do
  alias Translator.HTTPClient

  def get_languages() do
    HTTPClient.new()
    |> HTTPClient.get("languages")
  end

  def get_translation(message, target) do
    data = %{
      q: message,
      source: "auto",
      target: target
    }

    HTTPClient.new()
    |> HTTPClient.post("translate", data)
  end
end
