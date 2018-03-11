# Cachex-based interface to ETS
defmodule Tokenizer.Cache.ETS do

  @behaviour Tokenizer.Cache
  @cachex Cachex

  def get(key, cache \\ :tokens) do

    unless @cachex.ttl(cache, key) > 0 do
      delete(cache, key)
      response = {:error, "Token has expired"}
    else

      case @cachex.get(cache, key) do
        {:ok, nil} ->  {:error, "key #{key} not found"}
        {:ok, value} ->
          unless @cachex.ttl(cache, key) > 0 do
            delete(cache, key)
            response = {:error, "Token has expired"}
          else
            {:ok, value}
          end
        {:error, message} -> {:error, message}
        _ -> {:error, "Unexpected Behaviour"}
      end
    end
  end

  def delete(key, cache \\ :tokens) do
    @cachex.del(cache, key)
  end

  def update(key, data_list, cache \\ :tokens) do
    #TODO
    @cachex
  end

  def put(key, data, cache \\ :tokens) do
    response = case @cachex.put(cache, key, data) do
      {:ok, nil} -> {:error, "Could not push to #{key}"}
      {:ok, value} -> {:ok, value}
      {:error, message} -> {:error, message}
      _ -> {:error, "Unexpected Behaviour"}
    end

    if(is_integer(data[:expires_at])) do
      @cachex.expire_at(cache, key, data[:expires_at])
    end

    response
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
