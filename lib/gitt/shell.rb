# frozen_string_literal: true

require "dry/monads"
require "open3"

module Gitt
  # A low-level shell client.
  class Shell
    include Dry::Monads[:result]

    def initialize client: Open3
      @client = client
    end

    def call(*all, **)
      environment, arguments = all.partition { it.is_a? Hash }

      client.capture3(*environment, "git", *arguments, **).then do |stdout, stderr, status|
        status.success? ? Success(stdout) : Failure(stderr)
      end
    end

    private

    attr_reader :client
  end
end
