use Mix.Config

config :tokenizer,
  adapter: Tokenizer.Cache.ETS,
  token_expiration: 86400 #Expiration time in seconds
