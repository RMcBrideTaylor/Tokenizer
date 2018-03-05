# Tokenizer

Tokenizer is a library for generating, storing and checking OAuth tokens.

## Installation

  1. Add tokenizer to your list of dependencies in mix.exs:

        def deps do
          [{:tokenizer, "~> 0.0.1"}]
        end

  2. Ensure tokenizer is started before your application:

        def application do
          [applications: [:tokenizer]]
        end
