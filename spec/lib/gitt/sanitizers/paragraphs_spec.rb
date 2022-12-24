# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Paragraphs do
  subject(:sanitizer) { described_class }

  describe "#call" do
    it "answers paragraphs split by double new lines" do
      expect(sanitizer.call("one\n\ntwo")).to eq(%w[one two])
    end

    it "answers paragraphs with no trailing new line" do
      expect(sanitizer.call("one\n\ntwo\n")).to eq(%w[one two])
    end

    it "answer empty array when nil" do
      expect(sanitizer.call(nil)).to eq([])
    end
  end
end
