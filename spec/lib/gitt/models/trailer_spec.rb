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

  describe "#empty?" do
    it "answers true when key is nil and value exists" do
      expect(described_class[key: nil, value: "abc"].empty?).to be(true)
    end

    it "answers true when key is blank and value exists" do
      expect(described_class[key: "", value: "abc"].empty?).to be(true)
    end

    it "answers true when key exists but value is missing" do
      expect(described_class[key: "key", value: nil].empty?).to be(true)
    end

    it "answers true when key exists but value is blank" do
      expect(described_class[key: "key", value: ""].empty?).to be(true)
    end

    it "answers false when key and value exist" do
      expect(described_class[key: "key", value: "value"].empty?).to be(false)
    end
  end
end
