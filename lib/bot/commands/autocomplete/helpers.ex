defmodule Bot.Commands.Autocomplete.Helpers do
  def get_focused_options(options) do
    options
    |> List.wrap()
    |> Enum.find_value(&find_focused/1)
  end

  defp find_focused(%{focused: true} = opt), do: opt

  defp find_focused(%{options: nested}) when is_list(nested) do
    Enum.find_value(nested, &find_focused/1)
  end

  defp find_focused(_), do: nil

  def get_query(options) do
    case get_focused_options(options) do
      %{value: value} -> value
      _ -> ""
    end
  end
end
