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

      def initialize empty: EMPTY, pattern: PATTERN
        @empty = empty
        @pattern = pattern
      end

      # :reek:TooManyStatements
      def call text
        return empty unless text

        text.scan(pattern).each.with_object(empty.dup) do |(number, kind), stats|
          total = number.to_i

          case kind
            when "file" then stats[:files_changed] = total
            when "insertion" then stats[:insertions] = total
            when "deletion" then stats[:deletions] = total
            # :nocov:
          end
        end
      end

      private

      attr_reader :empty, :pattern
    end
  end
end
