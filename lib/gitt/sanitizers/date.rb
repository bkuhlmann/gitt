# frozen_string_literal: true

require "core"

module Gitt
  module Sanitizers
    Date = -> value { value.sub(/\s.+\Z/, Core::EMPTY_STRING) if value }
  end
end
