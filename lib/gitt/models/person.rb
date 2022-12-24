# frozen_string_literal: true

module Gitt
  module Models
    # Represents a person within a repository.
    Person = Struct.new :name, :delimiter, :email, keyword_init: true do
      def self.for(string, parser: Parsers::Person.new) = parser.call string

      def initialize *arguments
        super
        freeze
      end

      def to_s = values.join
    end
  end
end
