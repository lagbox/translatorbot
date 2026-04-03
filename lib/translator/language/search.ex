defmodule Translator.Language.Search do
  alias Translator.Language.Flags
  alias Translator.Persistence.UserPrefsMnesia

  @popular ~w(en es fr de zh ja ko pt ru)

  def search(languages, query, user_id) do
    query = String.downcase(query || "")
    user_data = UserPrefsMnesia.get_user_data(user_id)
    user_prefs = Map.keys(user_data.usage || %{})

    languages
    |> Enum.map(&score(&1, query, user_prefs))
    |> Enum.filter(fn {s, _} -> s > 0 end)
    |> Enum.sort_by(fn {s, _} -> -s end)
    |> Enum.take(25)
    |> Enum.map(&format/1)
  end

  def score(%{"name" => name, "code" => code} = lang, query, prefs) do
    name = String.downcase(name)
    code = String.downcase(code)

    base =
      cond do
        query == "" -> 1
        code == query -> 100
        name == query -> 95
        String.starts_with?(code, query) -> 90
        String.starts_with?(name, query) -> 85
        String.contains?(name, query) -> 70
        String.contains?(code, query) -> 65
        true -> jaro(name, query)
      end

    base = if code in @popular, do: base + 10, else: base
    base = if code in prefs, do: base + 15, else: base

    {base, lang}
  end

  defp jaro(name, query) do
    sim = String.jaro_distance(name, query)
    if sim > 0.8, do: round(sim * 60), else: 0
  end

  defp format({_, %{"name" => name, "code" => code}}) do
    flags = Flags.flags_for(code)

    %{
      name: "#{flags} #{name} (#{code})",
      value: code
    }
  end

  def bump_usage(user_id, lang) do
    UserPrefsMnesia.bump_usage(user_id, lang)
  end
end
