defmodule Translator.UserPrefsDets do
  @table :user_langs
  @file "user_langs.dets"

  def start_link do
    case :dets.open_file("@file", file: String.to_charlist("@file"), type: :set) do
      {:ok, _} -> {:ok, self()}
      {:error, reason} -> {:error, reason}
    end
  end

  def set_lang(user_id, lang) when is_integer(user_id) and is_binary(lang) do
    :dets.insert(@table, {user_id, lang})
    :ok
  rescue
    e -> {:error, e}
  end

  def get_lang(user_id) when is_integer(user_id) do
    case :dets.lookup(@table, user_id) do
      [{^user_id, lang}] -> lang
      [] -> nil
    end
  end

  def delete_lang(user_id) when is_integer(user_id) do
    :dets.delete(@table, user_id)
    :ok
  end

  def close do
    :dets.close(@table)
  end
end
