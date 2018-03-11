use Mix.Config

config :tokenizer,
  adapter: Tokenizer.Cache.MockETS,
  token_expiration: 1, #Expiration time in seconds
  refresh_token_expiration: 4 #Expiration time in seconds
