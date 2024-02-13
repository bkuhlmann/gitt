# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Trailers do
  subject(:sanitizer) { described_class.new }

  describe "#call" do
    it "answers records" do
      content = "One: 1\nTwo: 2"

      expect(sanitizer.call(content)).to eq(
        [
          Gitt::Models::Trailer[key: "One", value: "1"],
          Gitt::Models::Trailer[key: "Two", value: "2"]
        ]
      )
    end

    it "answers records where invalid trailers are ignored" do
      content = "One: 1\n2\n# Three\nFour: 4"

      expect(sanitizer.call(content)).to eq(
        [
          Gitt::Models::Trailer[key: "One", value: "1"],
          Gitt::Models::Trailer[key: "Four", value: "4"]
        ]
      )
    end

    it "answers empty array with nil value" do
      expect(sanitizer.call(nil)).to eq([])
    end

    it "answers empty array with empty value" do
      expect(sanitizer.call("")).to eq([])
    end
  end
end
