defmodule Tokenizer do
  use Application
  use Tokenizer.Cache.ETS
  use Tokenizer.Cache.MockETS
  use Tokenizer.Config

  ## OTP Supervisor Declarations
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Cachex/ETS Process
    cachex = [
      worker(Cachex, [:tokens, []]),
      worker(Cachex, [:refresh_tokens, []])
    ]
    cachex_opts = [strategy: :one_for_one, name: Tokenizer.Supervisor]

    # Mock Cachex/ETS Process
    mock_cachex = [
      worker(Tokenizer.Cache.MockETSBucket, [:tokens]),
      worker(Tokenizer.Cache.MockETSBucket, [:refresh_tokens])
    ]
    mock_cachex_opts = [strategy: :one_for_one, name: Tokenizer.Supervisor]

    # Start required cache
    case Application.get_env(:tokenizer, :adapter, Tokenizer.Cache.ETS) do
      Tokenizer.Cache.ETS -> Supervisor.start_link(cachex, cachex_opts)
      Tokenizer.Cache.MockETS -> Supervisor.start_link(mock_cachex, mock_cachex_opts)
    end
  end

  ## Interface description
  def generate_token(client, user, scope, depth \\ 1) when (is_integer(client) && is_integer(user)) do
    # Prevent inescapable loop
    unless depth < 1500 do
      {:error, "Could not generate token"}
    end

    # Generate key
    key = :crypto.strong_rand_bytes(255)

    if(!exists?(key)) do

      expiration_time = Time.add(Time.utc_now, Application.get_env(:tokenizer, :token_expiration, 86400))
      put(key, %{client: client, user: user, scope: scope, expires_at: expiration_time})

      case generate_refresh_token(client, user, scope) do
        {:ok, refresh_token} -> {:ok, {token: key, refresh_token: refresh_token}}
        {:error, message} -> {:error, message}
        _ -> raise UnexpectedBehaviourError
      end
    else
      generate_token(client, user, scope, depth + 1)
    end
  end

  def refresh_token(refresh_token) do
    case take(refresh_token, :refresh_tokens) do
      {:ok, nil} -> {:error, "token #{refresh_token} does not exist"}
      {:ok, body} -> generate_refresh_token(body[:client], body[:user], body[:scope]) #TODO: Delete old token here
      {:error, _message} -> {:error, "error finding token in cache"}
      _ -> raise UnexpectedBehaviourError
    end
  end

  def get(key, cache // :tokens) do
    @cache.get(key, cache)
  end

  def valid_token?(token) do
    case @cache.get(token, :tokens) do
      {:ok, _value} -> true
      _ -> false
    end

  end

  def valid_refresh_token?(token) do
    case @cache.get(token, :refresh_tokens) do
      {:ok, _value} -> true
      _ -> false
    end
  end


  # Helper methods
  defp generate_refresh_token(client, user, scope, depth \\ 1) when (is_integer(client) && is_integer(user)) do
    # Prevent inescapable loop
    unless depth < 1500 do
      {:error, "Could not generate refresh token"}
    end

    # Generate
    refresh_token = :crypto.strong_rand_bytes(255)

    if !exists?(refresh_token, :refresh_tokens) do
      expiration_time = Time.add(Time.utc_now, 2629746)
      put(refresh_token, %{client: client, user: user, scope: scope, expires_at: expiration_time}, :refresh_tokens)
      {:ok, refresh_token}
    else
      generate_refresh_token(client, user, scope, depth + 1)
    end
  end

  defp exists?(key, cache // :tokens) do
    @cache.exists?(key, cache)
  end

  defp take(key, cache // :tokens) do
    @cache.take(key, cache)
  end

  defp delete(key, cache // :tokens) do
    @cache.delete(key, cache)
  end

  defp update(key, new_value_keywordlist, cache // :tokens) do
    @cache.update(key, new_value_keywordlist, cache)
  end

  defp put(key, new_value, cache // :tokens) do
    @cache.put(key, new_value, cache)
  end


end
