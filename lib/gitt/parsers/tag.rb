# frozen_string_literal: true

require "refinements/hash"

module Gitt
  module Parsers
    # Parses raw tag information to produce a tag record.
    class Tag
      using Refinements::Hash

      def initialize attributer: Attributer.new(Commands::Tag::KEY_MAP.keys),
                     sanitizers: Sanitizers::CONTAINER,
                     model: Models::Tag
        @attributer = attributer
        @sanitizers = sanitizers
        @model = model
      end

      # :reek:TooManyStatements
      def call content
        attributes = attributer.call content
        body, trailers = attributes.values_at :body, :trailers
        sanitize attributes

        attributes[:body] = (
          trailers ? body.sub(/\n??#{Regexp.escape trailers}\n??/, "") : body
        ).to_s.chomp

        model[**attributes]
      end

      private

      attr_reader :attributer, :sanitizers, :model

      def sanitize attributes
        attributes.transform_with! author_email: email_sanitizer,
                                   authored_at: date_sanitizer,
                                   committed_at: date_sanitizer,
                                   committer_email: email_sanitizer,
                                   trailers: trailers_sanitizer,
                                   version: version_serializer
      end

      def date_sanitizer = sanitizers.fetch :date

      def email_sanitizer = sanitizers.fetch :email

      def trailers_sanitizer = sanitizers.fetch :trailers

      def version_serializer = sanitizers.fetch :version
    end
  end
end
