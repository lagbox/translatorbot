defmodule Translator.LibreTranslate do
  @url "http://localhost:5000/translate"
  @default_source "auto"

  def translate(text, target, opts \\ []) do
    source = Keyword.get(opts, :source, @default_source)

    case Req.post(@url,
           json: %{
             q: text,
             source: source,
             target: target,
             format: "text"
           }
         ) do
      {:ok, %{status: 200, body: body}} ->
        {:ok,
         %{
           translated: body["translatedText"],
           detected: body["detectedLanguage"]["language"]
         }}

      {:ok, %{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_detected_lang(%{"detectedLanguage" => %{"language" => lang}})
       when is_binary(lang),
       do: lang

  defp get_detected_lang(_), do: "auto"
end
