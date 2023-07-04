# frozen_string_literal: true

require "refinements/hashes"

module Gitt
  module Parsers
    # Parses raw trailer data to produce a trailer record.
    class Trailer
      using Refinements::Hashes

      PATTERN = /
        (?<key>\A.+)         # Key (anchored to start of line).
        (?<delimiter>:)      # Colon delimiter.
        (?<space>\s?)        # Space (optional).
        (?<value>.*?)        # Value.
        \Z                   # End of line.
      /x

      def initialize pattern: PATTERN, model: Models::Trailer
        @pattern = pattern
        @model = model
        @empty = model[key: nil, value: nil].to_h
      end

      def call content
        content.match(pattern)
               .then { |data| data ? data.named_captures : empty }
               .then { |attributes| model[**attributes.symbolize_keys!] }
      end

      private

      attr_reader :pattern, :model, :empty
    end
  end
end
