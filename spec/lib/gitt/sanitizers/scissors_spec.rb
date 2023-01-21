# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Scissors do
  subject(:sanitizer) { described_class }

  describe "#call" do
    it "answers content with scissors (verbosity) removed" do
      content = SPEC_ROOT.join("support/fixtures/commit-verbose.txt").read

      expect(sanitizer.call(content)).to eq(<<~CONTENT)
        Added commit with verbose option

        A fixture for a `git commit --verbose` commit.

      CONTENT
    end

    it "answers nil if given nil" do
      expect(sanitizer.call(nil)).to be(nil)
    end
  end
end
