defmodule TokenizerTest do
  use ExUnit.Case
  doctest Tokenizer

  test "properly generates tokens" do
    {code, _value} = Tokenizer.generate_token(1,2,"*")
    assert code == :ok
  end

  test "generates tokens of correct length" do
    {_code, value} = Tokenizer.generate_token(2,4,"*")

    assert (String.length(value.token) == 255 and String.length(value.refresh_token) == 255)
  end

  test "can access token after creation" do
    {_code, value} = Tokenizer.generate_token(2,4,"*")
    {code, response} = Tokenizer.get(value.token)

    assert (code == :ok && !is_nil(response))
  end

  test "allows refreshing of tokens" do
    {_code, value} = Tokenizer.generate_token(3,4,"*")
    {_new_code, new_value} = Tokenizer.refresh_token(value.refresh_token)

    assert(!is_nil(new_value.refresh_token) && new_value.refresh_token != value.refresh_token)
  end

  test "old refresh token is purged after refresh" do
    {_code, value} = Tokenizer.generate_token(5,4,"*")
    {_new_code, _new_value} = Tokenizer.refresh_token(value.refresh_token)

    {code, _response} = Tokenizer.get(value.refresh_token)
    assert code == :error
  end
end
