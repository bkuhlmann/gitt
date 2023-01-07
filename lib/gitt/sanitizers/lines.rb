# frozen_string_literal: true

require "core"

module Gitt
  module Sanitizers
    Lines = -> value { value ? value.split("\n") : Core::EMPTY_ARRAY }
  end
end
