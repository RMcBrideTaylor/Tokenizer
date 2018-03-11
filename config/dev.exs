use Mix.Config

config :tokenizer,
  adapter: Tokenizer.Cache.ETS,
  token_expiration: 60 #Expiration time in seconds
