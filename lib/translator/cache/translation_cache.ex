defmodule Translator.Cache.TranslationCache do
  @table :translation_cache

  def init do
    :ets.new(@table, [:named_table, :public, read_concurrency: true])
  rescue
    ArgumentError ->
      :ok
  end

  def get(key) do
    case :ets.lookup(@table, key) do
      [{^key, value, _ts}] ->
        value

      [] ->
        nil
    end
  end

  def put(key, value) do
    :ets.insert(@table, {key, value, now()})
    :ok
  end

  def delete(key) do
    :ets.delete(@table, key)
    :ok
  end

  def clear do
    :ets.delete_all_objects(@table)
    :ok
  end

  defp now, do: System.system_time(:second)
end
