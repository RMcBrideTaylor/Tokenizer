defmodule Tokenizer.Cache do
  @callback get(String.t, atom()) :: {:ok, term} | {:error, String.t}
  @callback delete(String.t, atom()) :: {:ok, term} | {:error, String.t}
  @callback update(String.t, Map.t, atom()) :: {:ok, term} | {:error, String.t}
  @callback expire(String.t, Integer.t, atom()) :: {:ok, term} | {:error, String.t}
  @callback put(String.t, any, atom()) :: {:ok, term} | {:error, String.t}
  @callback exists?(String.t, atom()) :: {:ok, term} | {:error, String.t}
  @callback take(String.t, atom()) :: {:ok, term} | {:error, String.t}
end
