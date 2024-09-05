# frozen_string_literal: true

module Gitt
  # Provides shared behavior for objects that have trailers.
  module Trailable
    def find_trailer key
      trailers.find { |trailer| trailer.key == key }
              .then do |trailer|
                return Success trailer if trailer

                Failure "Unable to find trailer for key: #{key.inspect}."
              end
    end

    def find_trailers key
      trailers.select { |trailer| trailer.key == key }
              .then { |trailers| Success trailers }
    end

    def trailer_value_for(key) = find_trailer(key).fmap(&:value)

    def trailer_values_for(key) = find_trailers(key).fmap { |trailers| trailers.map(&:value) }
  end
end
