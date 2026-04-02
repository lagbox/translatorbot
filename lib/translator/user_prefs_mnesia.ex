defmodule Translator.UserPrefsMnesia do
  require Logger
  @table :user_langs

  def init do
    case :mnesia.create_table(@table,
           attributes: [:user_id, :preferred, :usage],
           type: :set,
           disc_copies: [node()]
         ) do
      {:atomic, :ok} ->
        Logger.info("Created #{@table} table")

      {:aborted, {:already_exists, @table}} ->
        :ok

      {:aborted, reason} ->
        Logger.error("Mnesia create_table failed: #{inspect(reason)}")
    end
  end

  def set_preferred(user_id, lang) do
    case :mnesia.transaction(fn ->
           case :mnesia.read({@table, user_id}) do
             [{@table, ^user_id, _old_pref, usage}] ->
               :mnesia.write({@table, user_id, lang, usage || %{}})

             [] ->
               :mnesia.write({@table, user_id, lang, %{}})
           end
         end) do
      {:atomic, :ok} ->
        :ok

      {:aborted, reason} ->
        Logger.error("set_preferred failed: #{inspect(reason)}")
    end
  end

  def get_preferred(user_id) do
    case :mnesia.transaction(fn ->
           :mnesia.read({@table, user_id})
         end) do
      {:atomic, [{@table, ^user_id, pref, _usage}]} ->
        pref

      {:atomic, []} ->
        nil

      {:aborted, reason} ->
        Logger.error("get_preferred failed: #{inspect(reason)}")
        nil
    end
  end

  def bump_usage(user_id, lang) do
    case :mnesia.transaction(fn ->
           case :mnesia.read({@table, user_id}) do
             [{@table, ^user_id, pref, usage}] ->
               new_usage =
                 usage
                 |> (fn u -> u || %{} end).()
                 |> Map.update(lang, 1, &(&1 + 1))

               :mnesia.write({@table, user_id, pref, new_usage})

             [] ->
               :mnesia.write({@table, user_id, nil, %{lang => 1}})
           end
         end) do
      {:atomic, :ok} ->
        :ok

      {:aborted, reason} ->
        Logger.error("bump_usage failed: #{inspect(reason)}")
    end
  end

  def get_usage(user_id) do
    case :mnesia.transaction(fn ->
           :mnesia.read({@table, user_id})
         end) do
      {:atomic, [{@table, ^user_id, _pref, usage}]} ->
        usage || %{}

      {:atomic, []} ->
        %{}

      {:aborted, reason} ->
        Logger.error("get_usage failed: #{inspect(reason)}")
        %{}
    end
  end

  def get_user_data(user_id) do
    case :mnesia.transaction(fn ->
           :mnesia.read({@table, user_id})
         end) do
      {:atomic, [{@table, ^user_id, pref, usage}]} ->
        %{
          preferred: pref,
          usage: usage || %{}
        }

      {:atomic, []} ->
        %{
          preferred: nil,
          usage: %{}
        }

      {:aborted, reason} ->
        Logger.error("get_user_data failed: #{inspect(reason)}")

        %{
          preferred: nil,
          usage: %{}
        }
    end
  end

  def all do
    :mnesia.transaction(fn ->
      :mnesia.match_object({@table, :_, :_, :_})
    end)
  end

  def reset do
    :mnesia.transaction(fn ->
      :mnesia.clear_table(@table)
    end)
  end
end
