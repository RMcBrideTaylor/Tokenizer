defmodule Tokenizer.Cache do
  @callback get(String.t, atom()) :: {:ok, term} | {:error, String.t}
  @callback delete(String.t, atom()) :: {:ok, term} | {:error, String.t}
  @callback update(String.t, any, atom()) :: {:ok, term} | {:error, String.t}
  @callback put(String.t, any, atom()) :: {:ok, term} | {:error, String.t}
  @callback exists?(String.t, atom()) :: {:ok, term} | {:error, String.t}
end
