# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.then do |loader|
  loader.inflector.inflect "container" => "CONTAINER"
  loader.ignore "#{__dir__}/gitt/rspec/shared_contexts"
  loader.setup
end

# Main namespace.
module Gitt
  SHELL = Shell.new.freeze
end
