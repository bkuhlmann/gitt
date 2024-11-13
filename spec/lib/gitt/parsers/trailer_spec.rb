# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Parsers::Trailer do
  subject(:parser) { described_class.new }

  describe "#call" do
    it "answers record for valid content" do
      expect(parser.call("Test: abc")).to eq(
        Gitt::Models::Trailer[
          key: "Test",
          delimiter: ":",
          space: " ",
          value: "abc"
        ]
      )
    end

    it "answers record for value with special characters" do
      expect(parser.call("Test: https://test.io#test?query=test&limit=10")).to eq(
        Gitt::Models::Trailer[
          key: "Test",
          delimiter: ":",
          space: " ",
          value: "https://test.io#test?query=test&limit=10"
        ]
      )
    end

    it "answers record with key and delimiter only" do
      expect(parser.call("Test:")).to eq(
        Gitt::Models::Trailer[
          key: "Test",
          delimiter: ":",
          space: "",
          value: ""
        ]
      )
    end

    it "answers record with no space" do
      expect(parser.call("Test:abc")).to eq(
        Gitt::Models::Trailer[
          key: "Test",
          delimiter: ":",
          space: "",
          value: "abc"
        ]
      )
    end

    it "answers empty record for comment" do
      expect(parser.call("# A comment line.")).to eq(
        Gitt::Models::Trailer[
          key: nil,
          delimiter: ":",
          space: " ",
          value: nil
        ]
      )
    end

    it "answers empty record for invalid content" do
      expect(parser.call("bogus")).to eq(
        Gitt::Models::Trailer[
          key: nil,
          delimiter: ":",
          space: " ",
          value: nil
        ]
      )
    end
  end
end
