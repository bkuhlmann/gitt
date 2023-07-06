# frozen_string_literal: true

require "core"

module Gitt
  module Models
    # Represents a person within a repository.
    Person = Data.define :name, :delimiter, :email do
      def self.for(string, parser: Parsers::Person.new) = parser.call string

      def initialize name: nil, delimiter: " ", email: nil
        super
      end

      def to_s
        case self
          in String, String, String then "#{name}#{delimiter}<#{email}>"
          in String, String, nil then name
          in nil, String, String then "<#{email}>"
          else Core::EMPTY_STRING
        end
      end
    end
  end
end
