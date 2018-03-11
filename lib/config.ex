defmodule Tokenizer.Config do
  @moduledoc false
  defmacro __using__(_) do
    adapter = Application.get_env(:tokenizer, :adapter, Tokenizer.Cache.ETS)
    cond do
      (adapter && Enum.member?(adapter.module_info[:attributes][:behaviour], Tokenizer.Cache)) ->
        quote do
          alias unquote(adapter), as: Cache
        end

      (!Enum.member?(adapter.module_info[:attributes][:behaviour], Tokenizer.Cache)) ->
        raise UnexpectedBehaviourError, message: "Cache drivers must implement Tokenizer.Cache behaviour"

      (!Application.get_env(:tokenizer, :adapter)) ->
        raise ArgumentError, message: "Config :adapter not defined"
    end
  end
end
