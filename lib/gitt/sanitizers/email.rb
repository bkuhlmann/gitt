# frozen_string_literal: true

require "core"

module Gitt
  module Sanitizers
    Email = -> text { text.tr "<>", Core::EMPTY_STRING if text }
  end
end
