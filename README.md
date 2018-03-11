# Tokenizer

Tokenizer is a library for generating, storing and checking OAuth tokens.
## Upcoming

  1. Increasing code coverage
  2. Working on eliminating duplicate cache entries

## Installation

  1. Add tokenizer to your list of dependencies in mix.exs:

        def deps do
          [{:tokenizer, "https://github.com/RMcBrideTaylor/Tokenizer.git", "branch_name"}]
        end

  2. Ensure tokenizer is started before your application:

        def application do
          [applications: [:tokenizer]]
        end
