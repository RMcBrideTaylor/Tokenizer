defmodule Tokenizer.Cache.MockETS do
  use Agent
  @behaviour Tokenizer.Cache

  def get_all(cache \\ :tokens) do
    response = Agent.get(cache, fn set -> set end)
    case response do
      nil -> {:error, "entry not found"}
      response -> {:ok, response}
    end
  end

  def get(key, cache \\ :tokens) do
    response = Agent.get(cache, fn set ->
      set[key]
    end)

    case response do
      nil -> {:error, "entry not found"}
      response ->
        if (Time.diff(response.expires_at, Time.utc_now) >= 0) do
          {:ok, response}
        else
          {:error, "token has expired"}
        end
    end
  end

  def expire(key, time_in_seconds, cache \\ :tokens) do
    Agent.get_and_update(cache, fn set ->
      Map.get_and_update(set, key, fn data ->
        {data, Map.merge(data, %{expires_at: Time.add(Time.utc_now, time_in_seconds)})}
      end)
    end)
  end

  def take(key, cache \\ :tokens) do
    delete(key, cache)
  end

  def delete(key, cache \\ :tokens) do
    case Agent.get_and_update(cache, fn set -> Map.pop(set, key) end) do
      nil -> {:error, "Entry #{key} does not exist"}
      value -> {:ok, value}
    end
  end

  def update(key, data_list, cache \\ :tokens) do
    case Agent.get_and_update(cache, fn set ->

      if(Map.has_key?(set, key)) do
        updated_obj = set[key]

        Map.to_list(data_list) |> Enum.each(fn x ->
          map_key = Atom.to_string(elem(x,0))
          value = elem(x,1)

          if(Map.has_key?(updated_obj, map_key)) do
            updated_obj = Map.put(updated_obj, map_key, value)
          end
        end)

        {updated_obj, Map.put(set, key, updated_obj)}
      else
        {nil, set}
      end

    end) do
      nil -> {:error, "Entry #{key} does not exist"}
      value -> {:ok, value}
    end
  end

  def put(key, data, cache \\ :tokens) do
    case Agent.get_and_update(cache, fn set -> { data, Map.put(set, key, data)} end) do
      nil -> {:error, "Could not add entry"}
      value -> {:ok, value}
    end
  end

  def exists?(key, cache \\ :tokens) do
    case get(key, cache) do
      {:ok, _content} -> true
      _ -> false
    end
  end

end
