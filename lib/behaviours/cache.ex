defmodule Tokenizer.Cache do
  @callback get(String.t) :: {:ok, term} | {:error, String.t}
  @callback delete(String.t) :: {:ok, term} | {:error, String.t}
  @callback update(String.t, any) :: {:ok, term} | {:error, String.t}
  @callback put(String.t, any) :: {:ok, term} | {:error, String.t}
end
