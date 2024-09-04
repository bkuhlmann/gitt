# frozen_string_literal: true

require "core"
require "refinements/array"
require "strscan"

module Gitt
  module Sanitizers
    # Detects and parses paragraphs (including code blocks).
    class Paragraphs
      using Refinements::Array

      PATTERN = /
        (              # Condition start.
        (?:\..*?\n)?   # Optional ASCII Doc label.
        (?:\[.*\]\n)?  # Optional ASCII Doc directive.
        [-_=+\.\*]{4}  # ASCII Doc block start.
        [\s\S]*?       # Lazy block content of any character.
        [-_=+\.\*]{4}  # ASCII Doc block end.
        |              # Or.
        ```            # Markdown start.
        [\s\S]*?       # Lazy block content of any character.
        ```            # Markdown end.
        )              # Condition end.
      /mx

      def initialize pattern: PATTERN, client: StringScanner
        @pattern = pattern
        @client = client
      end

      def call(text) = scan(client.new(text.to_s))

      private

      attr_reader :pattern, :client

      # :reek:FeatureEnvy
      def scan scanner, collection = []
        until scanner.eos?
          match = scanner.scan_until pattern

          break collection << scanner.string[scanner.rest].tap(&:strip!).split("\n\n") unless match

          collection << scanner.pre_match.strip
          collection << scanner.captures
        end

        collection.tap(&:flatten!).tap(&:compress!)
      end
    end
  end
end
