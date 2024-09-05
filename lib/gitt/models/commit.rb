# frozen_string_literal: true

require "dry/monads"

module Gitt
  module Models
    # Represents commit details.
    Commit = Struct.new(
      :author_email,
      :author_name,
      :authored_at,
      :authored_relative_at,
      :body,
      :body_lines,
      :body_paragraphs,
      :committed_at,
      :committed_relative_at,
      :committer_email,
      :committer_name,
      :deletions,
      :encoding,
      :files_changed,
      :fingerprint,
      :fingerprint_key,
      :insertions,
      :lines,
      :notes,
      :raw,
      :sha,
      :signature,
      :subject,
      :trailers
    ) do
      include Directable
      include Trailable
      include Dry::Monads[:result]

      def initialize(**)
        super
        freeze
      end
    end
  end
end
