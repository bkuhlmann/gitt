# frozen_string_literal: true

module Gitt
  module Parsers
    # Extracts attributes from XML formatted content.
    class Attributer
      def self.with(...) = new(...)

      def initialize keys = []
        @keys = keys
      end

      def call content
        scrub = String(content).scrub "?"

        keys.reduce({}) do |attributes, key|
          attributes.merge key => scrub[%r(<#{key}>(?<value>.*?)</#{key}>)m, :value]
        end
      end

      private

      attr_reader :keys
    end
  end
end
