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

    def call(...)
      client.capture3("git", ...).then do |stdout, stderr, status|
        status.success? ? Success(stdout) : Failure(stderr)
      end
    end

    private

    attr_reader :client
  end
end
