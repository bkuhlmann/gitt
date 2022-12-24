# frozen_string_literal: true

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
      :lines,
      :raw,
      :sha,
      :signature,
      :subject,
      :trailers,
      keyword_init: true
    ) do
      def initialize *arguments
        super
        freeze
      end

      def amend? = subject.match?(/\Aamend!\s/)

      def fixup? = subject.match?(/\Afixup!\s/)

      def squash? = subject.match?(/\Asquash!\s/)

      def prefix? = amend? || fixup? || squash?
    end
  end
end
