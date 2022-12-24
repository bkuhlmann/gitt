# frozen_string_literal: true

module Gitt
  module Sanitizers
    Signature = lambda do |value|
      case value
        when "B" then "Bad"
        when "E" then "Error"
        when "G" then "Good"
        when "N" then "None"
        when "R" then "Revoked"
        when "U" then "Unknown"
        when "X" then "Expired"
        when "Y" then "Expired Key"
        else "Invalid"
      end
    end
  end
end
