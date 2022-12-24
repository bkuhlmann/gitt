# frozen_string_literal: true

module Gitt
  module Sanitizers
    CONTAINER = {
      date: Date,
      email: Email,
      lines: Lines,
      paragraphs: Paragraphs,
      scissors: Scissors,
      signature: Signature,
      trailers: Trailers.new
    }.freeze
  end
end
