defmodule Tokenizer.Config do
  defmacro __using__(_) do
    cond do
      (adapter = Application.get_env(:tokenizer, :adapter, Tokenizer.Cache.ETS) && Enum.member?(adapter.module_info[:attributes][:behaviour], Tokenizer.Cache)) ->
        quote do
          alias unquote(Application.get_env(:tokenizer, :adapter)) as: Cache
        end

      (!Enum.member?(adapter.module_info[:attributes][:behaviour], Tokenizer.Cache)) ->
        raise UnexpectedBehaviourError, message: "Cache drivers must implement Tokenizer.Cache behaviour"

      (!Application.get_env(:tokenizer, :adapter)) ->
        raise ArgumentError, message: "Config :adapter not defined"
    end
  end
end
