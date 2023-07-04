# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Parsers::Trailer do
  subject(:parser) { described_class.new }

  describe "#call" do
    it "answers record for valid content" do
      expect(parser.call("Test: abc")).to have_attributes(
        key: "Test",
        delimiter: ":",
        space: " ",
        value: "abc"
      )
    end

    it "answers record with key and delimiter only" do
      expect(parser.call("Test:")).to have_attributes(
        key: "Test",
        delimiter: ":",
        space: "",
        value: ""
      )
    end

    it "answers record with no space" do
      expect(parser.call("Test:abc")).to have_attributes(
        key: "Test",
        delimiter: ":",
        space: "",
        value: "abc"
      )
    end

    it "answers empty record for invalid content" do
      expect(parser.call("bogus")).to have_attributes(
        key: nil,
        delimiter: ":",
        space: " ",
        value: nil
      )
    end
  end
end
