# frozen_string_literal: true

module Gitt
  module Sanitizers
    # Sanitizes content by turning it into an array of trailer records.
    class Trailers
      def initialize parser: Parsers::Trailer.new
        @parser = parser
      end

      def call(value) = String(value).split("\n").map { |text| parser.call text }

      private

      attr_reader :parser
    end
  end
end
