# frozen_string_literal: true

require "dry/monads"

module Gitt
  module Commands
    # A Git branch command wrapper.
    class Branch
      include Dry::Monads[:result]

      def initialize shell: SHELL
        @shell = shell
      end

      def default fallback = "main"
        shell.call("config", "init.defaultBranch")
             .fmap(&:chomp)
             .fmap { |name| name.empty? ? fallback : name }
             .or(Success(fallback))
      end

      def call(*) = shell.call("branch", *)

      def name = shell.call("rev-parse", "--abbrev-ref", "HEAD").fmap(&:chomp)

      private

      attr_reader :shell
    end
  end
end
