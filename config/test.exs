use Mix.Config

config :tokenizer,
  adapter: Tokenizer.Cache.MockETS,
  token_expiration: 30 #Expiration time in seconds
