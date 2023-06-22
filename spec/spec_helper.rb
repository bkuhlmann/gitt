# frozen_string_literal: true

require "simplecov"

unless ENV["NO_COVERAGE"]
  SimpleCov.start do
    add_filter %r(^/(spec|lib/gitt/rspec/shared_contexts)/)
    enable_coverage :branch
    enable_coverage_for_eval
    minimum_coverage_by_file line: 95, branch: 95
  end
end

Bundler.require :tools

require "dry/monads"
require "gitt"
require "refinements"

SPEC_ROOT = Pathname(__dir__).realpath.freeze

using Refinements::Pathnames

Pathname.require_tree Bundler.root.join("lib/gitt/rspec/shared_contexts")

RSpec.configure do |config|
  include Dry::Monads[:result]

  config.color = true
  config.disable_monkey_patching!
  config.example_status_persistence_file_path = "./tmp/rspec-examples.txt"
  config.filter_run_when_matching :focus
  config.formatter = ENV.fetch("CI", false) == "true" ? :progress : :documentation
  config.order = :random
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.warnings = true

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end
end
