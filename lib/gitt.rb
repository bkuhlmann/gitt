# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.then do |loader|
  loader.ignore "#{__dir__}/gitt/shared_contexts"
  loader.setup
end

# Main namespace.
module Gitt
end
