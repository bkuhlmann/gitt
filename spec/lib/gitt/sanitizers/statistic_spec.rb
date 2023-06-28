# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Statistic do
  subject(:sanitizer) { described_class.new }

  describe "#call" do
    it "answers statistics when wrapped in new lines" do
      content = "\n 1 file changed, 2 insertions(+), 3 deletions(-)\n\n"
      expect(sanitizer.call(content)).to eq(files_changed: 1, insertions: 2, deletions: 3)
    end

    it "answers statistics when only file changes exist" do
      content = "1 file changed"
      expect(sanitizer.call(content)).to eq(files_changed: 1, insertions: 0, deletions: 0)
    end

    it "answers statistics when only file and insertion changes exist" do
      content = "1 file changed, 2 insertions"
      expect(sanitizer.call(content)).to eq(files_changed: 1, insertions: 2, deletions: 0)
    end

    it "answers statistics when only file and deletion changes exist" do
      content = "1 file changed, 2 deletions"
      expect(sanitizer.call(content)).to eq(files_changed: 1, insertions: 0, deletions: 2)
    end

    it "answers zeroed statistics when empty" do
      expect(sanitizer.call("")).to eq(files_changed: 0, insertions: 0, deletions: 0)
    end

    it "answers zeroed statistics when nil" do
      expect(sanitizer.call(nil)).to eq(files_changed: 0, insertions: 0, deletions: 0)
    end
  end
end
