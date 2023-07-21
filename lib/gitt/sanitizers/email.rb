# frozen_string_literal: true

require "core"

module Gitt
  module Sanitizers
    Email = -> value { value.tr "<>", Core::EMPTY_STRING if value }
  end
end
