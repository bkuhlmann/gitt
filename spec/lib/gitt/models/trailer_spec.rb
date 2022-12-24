# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Models::Trailer do
  subject(:trailer) { described_class.new }

  describe ".for" do
    it "answers records for content" do
      expect(described_class.for("Issue: 123")).to eq(
        described_class[key: "Issue", delimiter: ":", space: " ", value: "123"]
      )
    end
  end

  describe "#initialize" do
    it "answers frozen instance" do
      expect(trailer.frozen?).to be(true)
    end
  end

  describe "#to_s" do
    subject(:trailer) { described_class[key: "Test", delimiter: ":", space: " ", value: "abc"] }

    it "answers string with all attributes" do
      expect(trailer.to_s).to eq("Test: abc")
    end

    it "answers string with partial attributes" do
      trailer = described_class[key: "Test", value: "abc"]
      expect(trailer.to_s).to eq("Testabc")
    end

    it "answers empty string with no attributes" do
      expect(described_class.new.to_s).to eq("")
    end
  end
end
