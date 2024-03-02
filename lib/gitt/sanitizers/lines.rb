# frozen_string_literal: true

require "core"

module Gitt
  module Sanitizers
    Lines = -> text { text ? text.split("\n") : Core::EMPTY_ARRAY }
  end
end
