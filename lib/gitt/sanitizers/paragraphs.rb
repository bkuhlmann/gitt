# frozen_string_literal: true

require "core"

module Gitt
  module Sanitizers
    Paragraphs = -> text { text ? text.split("\n\n").map(&:chomp) : Core::EMPTY_ARRAY }
  end
end
