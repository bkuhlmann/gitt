# frozen_string_literal: true

module Gitt
  module Sanitizers
    # Converts raw text into a statistics hash.
    class Statistic
      EMPTY = {files_changed: 0, insertions: 0, deletions: 0}.freeze

      PATTERN = /
        (?<total>\d+)                     # Total capture group.
        \s                                # Space delimiter.
        (?<kind>file|insertion|deletion)  # Kind capture group.
      /x

      def self.update attributes, kind, total
        case kind
          when "file" then attributes[:files_changed] = total
          when "insertion" then attributes[:insertions] = total
          when "deletion" then attributes[:deletions] = total
          else fail StandardError, "Invalid kind: #{kind.inspect}."
        end
      end

      def initialize attributes = EMPTY, pattern: PATTERN
        @attributes = attributes
        @pattern = pattern
      end

      def call text
        return attributes unless text

        text.scan(pattern).each.with_object(attributes.dup) do |(number, kind), aggregate|
          self.class.update aggregate, kind, number.to_i
        end
      end

      private

      attr_reader :attributes, :pattern
    end
  end
end
