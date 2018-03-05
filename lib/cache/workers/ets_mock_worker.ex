defmodule Tokenizer.Cache.MockETSBucket do
  use Genserver

  def start_link(opts) do
    Agent.start_link(fn -> MapSet.new end, name: opts[1])
  end

end
