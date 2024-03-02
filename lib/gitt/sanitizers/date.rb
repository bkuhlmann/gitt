# frozen_string_literal: true

require "core"

module Gitt
  module Sanitizers
    Date = -> text { text.sub(/\s.+\Z/, Core::EMPTY_STRING) if text }
  end
end
