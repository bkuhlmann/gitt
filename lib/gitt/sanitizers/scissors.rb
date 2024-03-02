# frozen_string_literal: true

require "core"

module Gitt
  module Sanitizers
    Scissors = -> text { text.sub(/^#\s-.+\s>8\s-.+/m, Core::EMPTY_STRING) if text }
  end
end
