# frozen_string_literal: true

module Gitt
  module Models
    # Represents commit trailer details.
    Trailer = Struct.new :key, :delimiter, :space, :value, keyword_init: true do
      def self.for(string, parser: Parsers::Trailer.new) = parser.call string

      def initialize *arguments
        super
        freeze
      end

      def to_s = values.join
    end
  end
end
