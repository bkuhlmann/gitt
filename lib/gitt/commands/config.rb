# frozen_string_literal: true

require "core"
require "dry/monads"

module Gitt
  module Commands
    # A Git config command wrapper.
    class Config
      include Dry::Monads[:result]

      def initialize shell: SHELL
        @shell = shell
      end

      def call(*) = shell.call("config", *)

      def get(key, fallback = Core::EMPTY_STRING, *)
        call(*, "--get", key).fmap(&:chomp)
                             .or { |error| block_given? ? yield(error) : Success(fallback) }
      end

      def origin? = !get("remote.origin.url").value_or(Core::EMPTY_STRING).empty?

      def set(key, value, *) = call(*, "--add", key, value).fmap { value }

      private

      attr_reader :shell
    end
  end
end
