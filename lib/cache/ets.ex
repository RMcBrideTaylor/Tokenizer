# Cachex-based interface to ETS
defmodule Tokenizer.Cache.ETS do

  @behaviour Tokenizer.Cache
  @cachex Cachex

  def get(key, cache \\ :tokens) do
      case @cachex.get(cache, key) do
        {:ok, nil} ->  {:error, "key #{key} not found"}
        {:ok, value} ->
          {status, time} = @cachex.ttl(cache, key)
          unless time > 0 do
            delete(cache, key)
            response = {:error, "Token has expired"}
          else
            {:ok, value}
          end
        {:error, message} -> {:error, message}
        _ -> {:error, "Unexpected Behaviour"}
      end
  end

  def expire(key, time_in_seconds, cache \\ :tokens) do
    @cachex.expire(cache, key, :timer.seconds(time_in_seconds))
  end

  def delete(key, cache \\ :tokens) do
    @cachex.del(cache, key)
  end

  def update(key, data_list, cache \\ :tokens) do
    #TODO

    # Get request
    case get(key, cache) do
      {:ok, data} ->
        if is_map(data_list) and is_map(data) do

          new_data = Enum.reduce data, %{}, fn {key, value}, total ->
            if(Map.has_key?(data_list, key)) do
              Map.put(total, key, data_list[key])
            else
              Map.put(total, key, value)
            end
          end

          IO.inspect(put(key, new_data, cache))
           case put(key, new_data, cache) do
             {:ok, response} -> {:ok, response}
             {:error, message} -> {:error, message}
             _ -> {:error, "Unexpected Behaviour"}
           end

        else
          {:error, "Input and destination must both be type map"}
        end
      {:error, message} -> {:error, message}
      _ -> {:error, "Unexpected Behaviour"}
    end
  end

  def put(key, data, cache \\ :tokens) do
    case @cachex.put(cache, key, data) do
      {:ok, nil} -> {:error, "Could not push to #{key}"}
      {:ok, true} -> {:ok, data}
      {:error, message} -> {:error, message}
      _ -> {:error, "Unexpected Behaviour"}
    end
  end

  def take(key, cache \\ :tokens) do
    case @cachex.take(cache, key) do
      {:ok, nil} -> {:error, "key #{key} not found"}
      {:ok, value} -> {:ok, value}
      {:error, message} -> {:error, message}
      _ -> {:error, "Unexpected Behaviour"}
    end
  end

  def exists?(key, cache \\ :tokens) do
    case @cachex.exists?(cache, key) do
      {:ok, status} -> status
      _ -> {:error, "Unexpected Behaviour"}
    end
  end
end
