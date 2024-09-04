# frozen_string_literal: true

require "refinements/hash"

module Gitt
  module Parsers
    # Parses raw commit to produce a commit record.
    class Commit
      using Refinements::Hash

      def initialize attributer: Attributer.new(Commands::Log::KEY_MAP.keys.append(:statistics)),
                     sanitizers: Sanitizers::CONTAINER,
                     model: Models::Commit
        @attributer = attributer
        @sanitizers = sanitizers
        @model = model
      end

      def call content
        attributer.call(content)
                  .then { |attributes| mutate attributes }
                  .then { |attributes| model[**attributes] }
      end

      private

      attr_reader :attributer, :sanitizers, :model

      # :reek:TooManyStatements
      def mutate attributes
        body, trailers = attributes.values_at :body, :trailers
        body = scissors_sanitizer.call body

        attributes.transform_with! signature: signature_sanitizer, trailers: trailers_sanitizer

        attributes[:body] =
          (trailers ? body.sub(/\n??#{Regexp.escape trailers}\n??/, "") : body).chomp

        private_methods.grep(/\Aprocess_/).sort.each { |method| __send__ method, attributes }
        attributes
      end

      # :reek:FeatureEnvy
      def process_body_lines attributes
        attributes[:body_lines] = lines_sanitizer.call attributes[:body]
      end

      # :reek:FeatureEnvy
      def process_body_paragraphs attributes
        attributes[:body_paragraphs] = paragraphs_sanitizer.call attributes[:body]
      end

      # :reek:FeatureEnvy
      def process_lines attributes
        attributes[:lines] = lines_sanitizer.call attributes[:raw]
      end

      # :reek:FeatureEnvy
      def process_statistics attributes
        attributes.merge! statistic_sanitizer.call(attributes.delete(:statistics))
      end

      def lines_sanitizer = sanitizers.fetch :lines

      def paragraphs_sanitizer = sanitizers.fetch :paragraphs

      def scissors_sanitizer = sanitizers.fetch :scissors

      def statistic_sanitizer = sanitizers.fetch :statistic

      def signature_sanitizer = sanitizers.fetch :signature

      def trailers_sanitizer = sanitizers.fetch :trailers
    end
  end
end
