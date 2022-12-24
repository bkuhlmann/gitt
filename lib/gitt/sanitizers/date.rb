# frozen_string_literal: true

module Gitt
  module Sanitizers
    Date = -> value { value.sub(/\s.+\Z/, "") if value }
  end
end
