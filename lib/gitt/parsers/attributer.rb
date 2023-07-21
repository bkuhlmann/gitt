# frozen_string_literal: true

require "core"

module Gitt
  module Parsers
    # Extracts attributes from XML formatted content.
    class Attributer
      def initialize keys = Core::EMPTY_ARRAY
        @keys = keys
      end

      def call content
        build String(content)
      rescue ArgumentError => error
        error.message.include?("invalid byte") ? build(content.scrub("?")) : raise
      end

      private

      attr_reader :keys

      def build content
        keys.each.with_object({}) do |key, attributes|
          attributes[key] = content[%r(<#{key}>(?<value>.*?)</#{key}>)m, :value]
        end
      end
    end
  end
end
