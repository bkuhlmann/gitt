# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Date do
  subject(:sanitizer) { described_class }

  describe "#call" do
    it "removes time zone suffix" do
      expect(sanitizer.call("1668984438 -0700")).to eq("1668984438")
    end

    it "answer nil when nil" do
      expect(sanitizer.call(nil)).to be(nil)
    end
  end
end
