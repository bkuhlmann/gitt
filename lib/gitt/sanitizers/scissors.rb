# frozen_string_literal: true

module Gitt
  module Sanitizers
    Scissors = -> value { value.sub(/^#\s-.+\s>8\s-.+/m, "") if value }
  end
end
