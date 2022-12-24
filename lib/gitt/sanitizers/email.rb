# frozen_string_literal: true

module Gitt
  module Sanitizers
    Email = -> value { value.tr "<>", "" if value }
  end
end
