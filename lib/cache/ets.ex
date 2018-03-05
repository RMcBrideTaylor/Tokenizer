# Cachex-based interface to ETS
defmodule Tokenizer.Cache.ETS do
  use Cachex

  @behaviour Tokenizer.Cache
  @cache Cachex

  def get(key, cache // :tokens) do

    unless @cachex.ttl(cache, key) > 0 do
      delete(cache, key)
      {:error, "Token has expired"}
    else

      case @cachex.get(cache, key) do
        {:ok, nil} -> {:error, "key #{key} not found"}
        {:ok, value} -> {:ok, value}
        {:error, message} -> {:error, message}
        _ -> raise UnexpectedBehaviourError
      end

    end
  end

  def delete(key, cache // :tokens) do
    @cachex.del(cache, key)
  end

  def update(key, data, cache // :tokens) do
    @cachex #TODO
  end

  def put(key, data, cache // :tokens) do
    response = case @cachex.put(cache, key, data) do
      {:ok, nil} -> {:error, "Could not push to #{key}"}
      {:ok, value} -> {:ok, value}
      {:error, message} -> {:error, message}
      _ -> raise UnexpectedBehaviourError
    end

    if(is_integer(data[:expires_at])) do
      @cachex.expires_at(cache, key, data[:expires_at])
    end

    response
  end

  def take(key, cache // :tokens) do
    case @cachex.take(cache, key) do
      {:ok, nil} -> {:error, "key #{key} not found"}
      {:ok, value} -> {:ok, value}
      {:error, message} -> {:error, message}
      _ -> raise UnexpectedBehaviourError
    end
  end

  def exists?(key, cache // :tokens) do
    case @cachex.exists?(cache, key) do
      {:ok, status} -> status
      _ -> raise UnexpectedBehaviourError
    end
  end
end
