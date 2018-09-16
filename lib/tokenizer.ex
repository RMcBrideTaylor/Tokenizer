defmodule Tokenizer do
  use Application
  use Tokenizer.Config
  @cache Cache

  @moduledoc """
    This is the primary interface for the tokenizer application. It handles supervision,
    abstracting the cache interfaces, and performing operations against the cache
  """

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Cachex/ETS Process
    cachex = [
      worker(Cachex, [:tokens, []], [id: "tokens"]),
      worker(Cachex, [:refresh_tokens, []], [id: "refresh_tokens"])
    ]
    cachex_opts = [strategy: :one_for_one, name: Tokenizer.Supervisor]

    # Mock Cachex/ETS Process
    mock_cachex = [
      worker(Tokenizer.Cache.MockETSBucket, [:tokens], [id: "tokens"]),
      worker(Tokenizer.Cache.MockETSBucket, [:refresh_tokens], [id: "refresh_tokens"])
    ]
    mock_cachex_opts = [strategy: :one_for_one, name: Tokenizer.Supervisor]

    # Start required cache
    case Application.get_env(:tokenizer, :adapter, Tokenizer.Cache.ETS) do
      Tokenizer.Cache.ETS -> Supervisor.start_link(cachex, cachex_opts)
      Tokenizer.Cache.MockETS -> Supervisor.start_link(mock_cachex, mock_cachex_opts)
      _ -> throw UnexpectedBehaviourError
    end
  end

  @doc """
    Generates a new token in the cache for a given client, user, and scope

    Returns either an :ok or :error tuple message with an access / refresh token
  """
  def generate_token(client, resource, scope, type \\ :user, depth \\ 1) when is_integer(client) and is_integer(resource) and is_atom(type) do
    # Prevent inescapable loop
    unless depth < 1500 do
      {:error, "Could not generate token"}
    end

    # Generate key
    key = :crypto.strong_rand_bytes(255) |> Base.url_encode64 |> binary_part(0, 255)

    if(!exists?(key)) do

      put(key, %{client: client, resource: resource, scope: scope, type: type})
      expire(key, Application.get_env(:tokenizer, :token_expiration, 86400))

      case generate_refresh_token(client, resource, scope, type) do
        {:ok, refresh_token} -> {:ok, %{token: key, refresh_token: refresh_token, expires_in: Application.get_env(:tokenizer, :token_expiration, 86400)}}
        {:error, message} -> {:error, message}
        _ -> raise UnexpectedBehaviourError
      end
    else
      generate_token(client, resource, scope, type, depth + 1)
    end
  end


  @doc """
    Generates a new token in the cache from an existing refresh token

    Returns either an :ok or :error tuple message with an access / refresh token
  """
  def refresh_token(refresh_token) when is_bitstring(refresh_token) do
    case take(refresh_token, :refresh_tokens) do
      {:ok, nil} -> {:error, "Token does not exist."}
      {:ok, body} -> generate_token(body[:client], body[:resource], body[:scope], body[:type])
      {:error, _message} -> {:error, "error finding token in cache"}
      _ -> raise UnexpectedBehaviourError
    end
  end

  @doc """
    Fetches a cache entry associated with a token string

    Returns either an :ok or :error tuple message with an access / refresh token
  """
  def get(key, cache \\ :tokens) when is_bitstring(key) and is_atom(cache) do
    @cache.get(key, cache)
  end

  @doc """
    Checks that a cache entry exists for a given token

    Returns either true or false
  """
  def valid_token?(token) when is_bitstring(token) do
    case @cache.get(token, :tokens) do
      {:ok, _value} -> true
      _ -> false
    end

  end

  @doc """
    Checks that a cache entry exists for a given refresh token

    Returns either true or false
  """
  def valid_refresh_token?(token) when is_bitstring(token) do
    case @cache.get(token, :refresh_tokens) do
      {:ok, _value} -> true
      _ -> false
    end
  end

  # Helper methods
  @doc false
  defp generate_refresh_token(client, resource, scope, type \\ :user, depth \\ 1) when is_integer(resource) and is_atom(type) do
    # Prevent inescapable loop
    unless depth < 1500 do
      {:error, "Could not generate refresh token"}
    end

    # Generate
    refresh_token = :crypto.strong_rand_bytes(255) |> Base.url_encode64 |> binary_part(0, 255)

    if !exists?(refresh_token, :refresh_tokens) do
      put(refresh_token, %{client: client, resource: resource, scope: scope, type: type}, :refresh_tokens)
      expire(refresh_token, Application.get_env(:tokenizer, :refresh_token_expiration, 86400), :refresh_tokens)
      {:ok, refresh_token}
    else
      generate_refresh_token(client, resource, scope, type, depth + 1)
    end
  end

  @doc false
  defp expire(key, time_in_seconds, cache \\ :tokens) when is_bitstring(key) and is_integer(time_in_seconds) and is_atom(cache) do
    @cache.expire(key, time_in_seconds, cache)
  end

  @doc false
  defp exists?(key, cache \\ :tokens) when is_bitstring(key) and is_atom(cache) do
    @cache.exists?(key, cache)
  end

  @doc false
  defp take(key, cache \\ :tokens) when is_bitstring(key) and is_atom(cache) do
    @cache.take(key, cache)
  end

  @doc false
  defp delete(key, cache \\ :tokens) when is_bitstring(key) and is_atom(cache) do
    @cache.delete(key, cache)
  end

  @doc false
  defp put(key, new_value, cache \\ :tokens) when is_bitstring(key) and is_atom(cache) do
    @cache.put(key, new_value, cache)
  end

  @doc false
  defp update(key, new_value_map, cache \\ :tokens) when is_bitstring(key) and is_map(new_value_map) and is_atom(cache) do
    @cache.update(key, new_value_map, cache)
  end

end
