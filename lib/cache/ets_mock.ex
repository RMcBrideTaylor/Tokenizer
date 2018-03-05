defmodule Tokenizer.Cache.MockETS do
  @behaviour Tokenizer.Cache

  def get(key, cache // :tokens) do
    response = Agent.get(cache, fn set ->
      set[key]
    end)

    case response do
      nil -> {:error, "entry not found"}
      response -> {:ok, response}
    end
  end

  def delete(key, cache // :tokens) do

  end

  def update(key, data, cache // :tokens) do

  end

  def put(key, data, cache // :tokens) do

  end

  def exists?(key, cache // :tokens) do
    
  end

end
