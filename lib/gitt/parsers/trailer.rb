# frozen_string_literal: true

module Gitt
  module Parsers
    # Parses raw trailer data to produce a trailer record.
    class Trailer
      PATTERN = /
        \A                  # Start of line.
        (?<key>[a-zA-Z-]+)  # Key.
        (?<delimiter>:)     # Delimiter (colon).
        (?<space>\s?)       # Space (optional).
        (?<value>.*?)       # Value.
        \Z                  # End of line.
      /x

      EMPTY = Models::Trailer[key: nil, value: nil]

      def initialize pattern: PATTERN, model: Models::Trailer, empty: EMPTY
        @pattern = pattern
        @model = model
        @empty = empty
      end

      def call content
        return empty if content.start_with? "#"

        content.match(pattern)
               .then { |data| data ? model[**data.named_captures(symbolize_names: true)] : empty }
      end

      private

      attr_reader :pattern, :model, :empty
    end
  end
end
