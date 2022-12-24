# frozen_string_literal: true

module Gitt
  module Sanitizers
    Lines = -> value { value ? value.split("\n") : EMPTY_ARRAY }
  end
end
