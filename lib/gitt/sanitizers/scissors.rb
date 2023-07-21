# frozen_string_literal: true

require "core"

module Gitt
  module Sanitizers
    Scissors = -> value { value.sub(/^#\s-.+\s>8\s-.+/m, Core::EMPTY_STRING) if value }
  end
end
