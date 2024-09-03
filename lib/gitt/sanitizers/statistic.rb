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

      def self.update_stats attributes, kind, total
        case kind
          when "file" then attributes[:files_changed] = total
          when "insertion" then attributes[:insertions] = total
          when "deletion" then attributes[:deletions] = total
          else fail StandardError, "Invalid kind: #{kind.inspect}."
        end
      end

      def initialize empty: EMPTY, pattern: PATTERN
        @empty = empty
        @pattern = pattern
      end

      def call text
        return empty unless text

        text.scan(pattern).each.with_object(empty.dup) do |(number, kind), aggregate|
          self.class.update_stats aggregate, kind, number.to_i
        end
      end

      private

      attr_reader :empty, :pattern
    end
  end
end
