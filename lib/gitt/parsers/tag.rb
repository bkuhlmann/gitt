# frozen_string_literal: true

require "refinements/hashes"

module Gitt
  module Parsers
    # Parses raw tag information to produce a tag record.
    class Tag
      using Refinements::Hashes

      def initialize attributer: Attributer.new(Commands::Tag::KEY_MAP.keys),
                     sanitizers: Sanitizers::CONTAINER,
                     model: Models::Tag
        @attributer = attributer
        @sanitizers = sanitizers
        @model = model
      end

      def call content
        attributes = attributer.call content
        attributes.transform_with! author_email: email_sanitizer,
                                   authored_at: date_sanitizer,
                                   committed_at: date_sanitizer,
                                   committer_email: email_sanitizer,
                                   version: -> value { value.delete_prefix "refs/tags/" if value }
        model[**attributes]
      end

      private

      attr_reader :attributer, :sanitizers, :model

      def date_sanitizer = sanitizers.fetch(:date)

      def email_sanitizer = sanitizers.fetch(:email)
    end
  end
end
