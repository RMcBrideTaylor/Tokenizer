# Cachex-based interface to ETS
defmodule Tokenizer.Cache.ETS do
  @behaviour Tokenizer.Cache

  def get(key, cache // :tokens) do

    unless Cachex.ttl(cache, key) > 0 do
      delete(cache, key)
      {:error, "Token has expired"}
    else

      case Cachex.get(cache, key) do
        {:ok, nil} -> {:error, "key #{key} not found"}
        {:ok, value} -> {:ok, value}
        {:error, message} -> {:error, message}
        _ -> raise UnexpectedBehaviourError
      end

    end
  end

  def delete(key, cache // :tokens) do
    Cachex.del(cache, key)
  end

  def update(key, data, cache // :tokens) do
    Cachex
  end

  def put(key, data, cache // :tokens) do
    response = case Cachex.put(cache, key, data) do
      {:ok, nil} -> {:error, "Could not push to #{key}"}
      {:ok, value} -> {:ok, value}
      {:error, message} -> {:error, message}
      _ -> raise UnexpectedBehaviourError
    end

    if(is_integer(data[:expires_at])) do
      Cachex.expires_at(cache, key, data[:expires_at])
    end

    response
  end

  def take(key, cache // :tokens) do
    case Cachex.take(cache, key) do
      {:ok, nil} -> {:error, "key #{key} not found"}
      {:ok, value} -> {:ok, value}
      {:error, message} -> {:error, message}
      _ -> raise UnexpectedBehaviourError
    end
  end

  def exists?(key, cache // :tokens) do
    case Cachex.exists?(cache, key) do
      {:ok, status} -> status
      _ -> raise UnexpectedBehaviourError
    end
  end
end
