# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Models::Trailer do
  subject(:trailer) { described_class[key: "issue", value: "123"] }

  describe ".for" do
    it "answers records for content" do
      expect(described_class.for("issue: 123")).to eq(described_class[key: "issue", value: "123"])
    end
  end

  describe "#to_s" do
    it "answers string of required attributes" do
      expect(trailer.to_s).to eq("issue: 123")
    end

    it "answers string of custom attributes" do
      trailer = described_class[key: "test", delimiter: " -", space: "  ", value: "abc"]
      expect(trailer.to_s).to eq("test -  abc")
    end

    it "answers empty string of nil attributes" do
      expect(described_class[key: nil, delimiter: nil, space: nil, value: nil].to_s).to eq("")
    end
  end
end
