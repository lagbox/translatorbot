defmodule Translator.LibreTranslate do
  @moduledoc """
  Wrapper for LibreTranslate using Req.
  """

  @url "http://localhost:5000/translate"
  @default_source "auto"

  # def translate(text, target, opts \\ []) do
  #   source = Keyword.get(opts, :source, @default_source)

  #   case Req.post(@url,
  #          json: %{
  #            q: text,
  #            source: source,
  #            target: target,
  #            format: "text"
  #          }
  #        ) do
  #     {:ok, %{status: 200, body: body}} ->
  #       {:ok,
  #        %{
  #          translated: body["translatedText"],
  #          detected: body["detectedLanguage"]["language"]
  #        }}

  #     {:ok, %{status: status}} ->
  #       {:error, {:http_error, status}}

  #     {:error, reason} ->
  #       {:error, reason}
  #   end
  # end

  # Optional source (defaults to "auto")
  def translate(text, target), do: translate(text, target, "auto")

  def translate(text, target, source)
      when is_binary(text) and is_binary(target) do
    body = %{
      q: text,
      source: source || "auto",
      target: target,
      format: "text"
    }

    case Req.post(@url, json: body) do
      {:ok, %{status: 200, body: resp}} ->
        {:ok,
         %{
           translated: resp["translatedText"],
           detected: get_detected_lang(resp)
         }}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # ----------------------------------
  # Helpers
  # ----------------------------------

  defp get_detected_lang(%{"detectedLanguage" => %{"language" => lang}})
       when is_binary(lang),
       do: lang

  defp get_detected_lang(_), do: "auto"
end
