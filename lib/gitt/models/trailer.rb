# frozen_string_literal: true

module Gitt
  module Models
    # Represents commit trailer details.
    Trailer = Data.define :key, :delimiter, :space, :value do
      def self.for(string, parser: Parsers::Trailer.new) = parser.call string

      def initialize key:, value:, delimiter: ":", space: " "
        super
      end

      def empty? = String(key).empty? || String(value).empty?

      def to_s = to_h.values.join
    end
  end
end
