# frozen_string_literal: true

require "dry/monads"

module Gitt
  module Commands
    # A Git config command wrapper.
    class Config
      include Dry::Monads[:result]

      def initialize shell: SHELL
        @shell = shell
      end

      def call(*arguments) = shell.call "config", *arguments

      def get key, fallback = "", *arguments
        call(*arguments, "--get", key).fmap(&:chomp)
                                      .or do |error|
                                        block_given? ? yield(error) : Success(fallback)
                                      end
      end

      def origin? = !get("remote.origin.url").value_or(EMPTY_STRING).empty?

      def set(key, value, *arguments) = call(*arguments, "--add", key, value).fmap { value }

      private

      attr_reader :shell
    end
  end
end
