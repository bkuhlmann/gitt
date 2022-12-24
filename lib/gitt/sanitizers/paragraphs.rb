# frozen_string_literal: true

module Gitt
  module Sanitizers
    Paragraphs = -> value { value ? value.split("\n\n").map(&:chomp) : EMPTY_ARRAY }
  end
end
