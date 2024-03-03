# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Version do
  subject(:sanitizer) { described_class }

  describe "#call" do
    it "answers version" do
      expect(sanitizer.call("refs/tags/0.0.0")).to eq("0.0.0")
    end

    it "answers nil if given nil" do
      expect(sanitizer.call(nil)).to be(nil)
    end
  end
end
