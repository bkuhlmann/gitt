# frozen_string_literal: true

require "dry/monads"

module Gitt
  module Models
    # Represents commit details.
    Commit = Struct.new(
      :author_email,
      :author_name,
      :authored_at,
      :authored_relative_at,
      :body,
      :body_lines,
      :body_paragraphs,
      :committed_at,
      :committed_relative_at,
      :committer_email,
      :committer_name,
      :deletions,
      :encoding,
      :files_changed,
      :insertions,
      :lines,
      :notes,
      :raw,
      :sha,
      :signature,
      :subject,
      :trailers
    ) do
      include Directable
      include Dry::Monads[:result]

      def initialize(**)
        super
        freeze
      end

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
end
