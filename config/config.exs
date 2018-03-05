# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :tokenizer,
  adapter: Tokenizer.Cache.ETS,
  token_expiration: 86400, #Expiration time in seconds
