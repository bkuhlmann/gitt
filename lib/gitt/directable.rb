# frozen_string_literal: true

module Gitt
  # Provides shared behavior for objects that can act like a commit.
  module Directable
    def directive? = amend? || fixup? || squash?

    def amend? = subject.match?(/\Aamend!\s/)

    def fixup? = subject.match?(/\Afixup!\s/)

    def squash? = subject.match?(/\Asquash!\s/)

    def prefix = subject[/\A[\w!]+/]
  end
end
