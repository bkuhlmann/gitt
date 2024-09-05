# frozen_string_literal: true

module Gitt
  module Models
    # Represents tag details.
    Tag = Struct.new(
      :author_email,
      :author_name,
      :authored_at,
      :authored_relative_at,
      :body,
      :committed_at,
      :committed_relative_at,
      :committer_email,
      :committer_name,
      :sha,
      :signature,
      :subject,
      :trailers,
      :version
    ) do
      include Trailable

      def initialize(**)
        super
        freeze
      end
    end
  end
end
