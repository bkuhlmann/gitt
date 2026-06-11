# frozen_string_literal: true

require "core"
require "strscan"

module Gitt
  module Sanitizers
    # Detects and parses paragraphs (including code blocks).
    class Paragraphs
      PATTERN = /
        (            # Condition start.
        (?:          # Opens non-capture group.
        \.           # Dot character.
        (?!\s)       # Negative look ahead for whitespace character.
        [^\n]*?      # Non-greedy match for non-whitespace characters.
        \n           # New line character.
        )            # End of non-capture group.
        ?            # Makes above capture group optional.
        (?:          # Opens non-capture group.
        \[           # Open bracket character.
        .*           # Greedy matches any character zero or more times.
        \]           # Close bracket character.
        \n           # New line character.
        )            # Closes non-capture group.
        ?            # Makes above capture group optional.
        [-_=+.*]{4}  # ASCII Doc block start.
        [\s\S]*?     # Lazy block content with any character.
        [-_=+.*]{4}  # ASCII Doc block end.
        |            # Or.
        ```          # Markdown start.
        [\s\S]*?     # Lazy block content with any character.
        ```          # Markdown end.
        )            # Condition end.
      /mx

      def initialize pattern: PATTERN, client: StringScanner
        @pattern = pattern
        @client = client
      end

      def call(text) = scan client.new(text.to_s)

      private

      attr_reader :pattern, :client

      # :reek:FeatureEnvy
      def scan scanner, collection = []
        until scanner.eos?
          match = scanner.scan_until pattern

          break collection.concat scanner.rest.strip.split("\n\n") unless match

          collection.concat scanner.pre_match.strip.split("\n\n").drop(collection.length)
          collection << scanner.captures
        end

        collection.tap(&:flatten!)
      end
    end
  end
end
