defmodule Tokenizer.Cache.MockETSBucket do
  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> Map.new end, name: opts)
  end

end
