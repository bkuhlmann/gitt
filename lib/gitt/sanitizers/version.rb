# frozen_string_literal: true

require "core"

module Gitt
  module Sanitizers
    Version = -> text { text.delete_prefix "refs/tags/" if text }
  end
end
