# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Statistic do
  subject(:sanitizer) { described_class.new }

  describe ".update_stats" do
    let(:attributes) { Hash.new }

    it "updates files changed" do
      described_class.update_stats attributes, "file", 1
      expect(attributes).to eq(files_changed: 1)
    end

    it "updates insertions" do
      described_class.update_stats attributes, "insertion", 1
      expect(attributes).to eq(insertions: 1)
    end

    it "updates deletions" do
      described_class.update_stats attributes, "deletion", 1
      expect(attributes).to eq(deletions: 1)
    end

    it "fails with unknown kind" do
      expectation = proc { described_class.update_stats attributes, "bogus", 1 }
      expect(&expectation).to raise_error(StandardError, %(Invalid kind: "bogus".))
    end
  end

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
