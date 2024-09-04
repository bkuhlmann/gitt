# frozen_string_literal: true

module Gitt
  module Sanitizers
    CONTAINER = {
      date: Date,
      email: Email,
      lines: Lines,
      paragraphs: Paragraphs.new,
      scissors: Scissors,
      signature: Signature,
      statistic: Statistic.new,
      trailers: Trailers.new,
      version: Version
    }.freeze
  end
end
