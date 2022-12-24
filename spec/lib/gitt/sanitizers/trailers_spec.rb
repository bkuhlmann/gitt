# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Trailers do
  subject(:sanitizer) { described_class.new }

  describe "#call" do
    it "answers records" do
      content = "One: 1\nTwo: 2"

      expect(sanitizer.call(content)).to eq(
        [
          Gitt::Models::Trailer[key: "One", delimiter: ":", space: " ", value: "1"],
          Gitt::Models::Trailer[key: "Two", delimiter: ":", space: " ", value: "2"]
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
