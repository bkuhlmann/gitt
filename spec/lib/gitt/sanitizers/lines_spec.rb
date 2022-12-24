# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Lines do
  subject(:sanitizer) { described_class }

  describe "#call" do
    it "answers lines split by new line" do
      expect(sanitizer.call("one\ntwo")).to eq(%w[one two])
    end

    it "answer empty array when nil" do
      expect(sanitizer.call(nil)).to eq([])
    end
  end
end
