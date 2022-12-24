# frozen_string_literal: true

module Gitt
  module Parsers
    # Parses raw trailer data to produce a trailer record.
    class Person
      PATTERN = /
        \A                 # Start of line.
        (?<name>.*?)       # Name (smallest possible).
        (?<delimiter>\s?)  # Space delimiter (optional).
        (?<email><.+>)?    # Collaborator email (optional).
        \Z                 # End of line.
      /x

      def initialize model: Models::Person, pattern: PATTERN
        @pattern = pattern
        @model = model
      end

      def call(content) = model[content.match(pattern).named_captures]

      private

      attr_reader :pattern, :model
    end
  end
end
