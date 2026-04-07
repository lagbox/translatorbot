defmodule Translator.Language.Flags do
  @map %{
    "en" => ["US", "GB"],
    "es" => ["ES", "MX"],
    "pt" => ["BR", "PT"],
    "zh" => ["CN", "TW"],
    "ar" => ["SA", "EG"],
    "fr" => ["FR", "CA"],
    "de" => ["DE", "AT"],
    "nl" => ["NL", "BE"],
    "af" => ["ZA"],
    "sq" => ["AL"],
    "am" => ["ET"],
    "hy" => ["AM"],
    "az" => ["AZ"],
    "eu" => ["ES"],
    "be" => ["BY"],
    "bn" => ["BD"],
    "bs" => ["BA"],
    "bg" => ["BG"],
    "ca" => ["ES"],
    "ceb" => ["PH"],
    "ny" => ["MW"],
    "co" => ["FR"],
    "hr" => ["HR"],
    "cs" => ["CZ"],
    "da" => ["DK"],
    "eo" => ["🌐"],
    "et" => ["EE"],
    "tl" => ["PH"],
    "fi" => ["FI"],
    "fy" => ["NL"],
    "gl" => ["ES"],
    "ka" => ["GE"],
    "el" => ["GR"],
    "gu" => ["IN"],
    "ht" => ["HT"],
    "ha" => ["NG"],
    "haw" => ["US"],
    "he" => ["IL"],
    "hi" => ["IN"],
    "hmn" => ["LA"],
    "hu" => ["HU"],
    "is" => ["IS"],
    "ig" => ["NG"],
    "id" => ["ID"],
    "ga" => ["IE"],
    "it" => ["IT"],
    "ja" => ["JP"],
    "jw" => ["ID"],
    "kn" => ["IN"],
    "kk" => ["KZ"],
    "km" => ["KH"],
    "ko" => ["KR"],
    "ku" => ["IQ"],
    "ky" => ["KG"],
    "lo" => ["LA"],
    "la" => ["VA"],
    "lv" => ["LV"],
    "lt" => ["LT"],
    "lb" => ["LU"],
    "mk" => ["MK"],
    "mg" => ["MG"],
    "ms" => ["MY"],
    "ml" => ["IN"],
    "mt" => ["MT"],
    "mi" => ["NZ"],
    "mr" => ["IN"],
    "mn" => ["MN"],
    "my" => ["MM"],
    "ne" => ["NP"],
    "no" => ["NO"],
    "or" => ["IN"],
    "ps" => ["AF"],
    "fa" => ["IR"],
    "pl" => ["PL"],
    "pa" => ["IN"],
    "ro" => ["RO"],
    "ru" => ["RU"],
    "sm" => ["WS"],
    "gd" => ["GB"],
    "sr" => ["RS"],
    "st" => ["LS"],
    "sn" => ["ZW"],
    "sd" => ["PK"],
    "si" => ["LK"],
    "sk" => ["SK"],
    "sl" => ["SI"],
    "so" => ["SO"],
    "su" => ["ID"],
    "sw" => ["KE"],
    "sv" => ["SE"],
    "tg" => ["TJ"],
    "ta" => ["IN"],
    "te" => ["IN"],
    "th" => ["TH"],
    "tr" => ["TR"],
    "uk" => ["UA"],
    "ur" => ["PK"],
    "uz" => ["UZ"],
    "vi" => ["VN"],
    "cy" => ["GB"],
    "xh" => ["ZA"],
    "yi" => ["IL"],
    "yo" => ["NG"],
    "zu" => ["ZA"]
  }

  @flag_priority %{
    "ES" => ["es"],
    "MX" => ["es"],
    "US" => ["en"],
    "GB" => ["en"],
    "BR" => ["pt"],
    "PT" => ["pt"],
    "CN" => ["zh"],
    "TW" => ["zh"],
    "SA" => ["ar"],
    "FR" => ["fr"],
    "DE" => ["de"],
    "NG" => ["yo", "ig", "ha"],
    "IN" => ["hi", "en"]
  }

  # language → flags (emoji string)
  def flags_for(code) do
    code
    |> String.downcase()
    |> then(&Map.get(@map, &1, ["🌐"]))
    |> Enum.take(2)
    |> Enum.map_join("", &to_flag/1)
  end

  # flag → languages (weighted)
  def codes_for_flag(flag) do
    case langs = reverse_map() |> Map.get(flag, []) do
      [] ->
        []

      _ ->
        country = flag_to_country(flag)
        priority = Map.get(@flag_priority, country, [])

        Enum.sort_by(langs, fn lang ->
          case Enum.find_index(priority, &(&1 == lang)) do
            nil -> 999
            idx -> idx
          end
        end)
    end
  end

  def primary_language(flag), do: code_for_flag(flag)

  def code_for_flag(flag) do
    case codes_for_flag(flag) do
      [lang | _] -> {:ok, lang}
      _ -> :error
    end
  end

  # multi-flag string → merged languages
  def codes_for_any_flag(flag_string) do
    flag_string
    |> split_flags()
    |> Enum.flat_map(&codes_for_flag/1)
    |> Enum.uniq()
  end

  def is_flag?(emoji) do
    String.match?(emoji, ~r/[🇦-🇿]{2}|🌐/u)
    # String.match?(emoji, ~r/[\x{1F1E6}-\x{1F1FF}]{2}|🌐/u)
  end

  defp reverse_map do
    Enum.reduce(@map, %{}, fn {lang, countries}, acc ->
      Enum.reduce(countries, acc, fn country, acc2 ->
        flag = to_flag(country)

        Map.update(acc2, flag, [lang], fn langs ->
          [lang | langs]
        end)
      end)
    end)
  end

  defp split_flags(str) do
    str
    |> String.graphemes()
    |> Enum.chunk_every(2)
    |> Enum.map(&Enum.join/1)
  end

  defp flag_to_country(<<f1::utf8, f2::utf8>>) do
    base = 0x1F1E6
    <<f1 - base + ?A, f2 - base + ?A>>
  end

  defp flag_to_country(_), do: nil

  defp to_flag("🌐"), do: "🌐"

  defp to_flag(<<c1::utf8, c2::utf8>>) do
    base = 0x1F1E6
    <<base + c1 - ?A::utf8, base + c2 - ?A::utf8>>
  end
end
