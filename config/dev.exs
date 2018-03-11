use Mix.Config

config :tokenizer,
  adapter: Tokenizer.Cache.ETS,
  token_expiration: 60, #Expiration time in seconds
  refresh_token_expiration: 3600 #Expiration time in seconds
