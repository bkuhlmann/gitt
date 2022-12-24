# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Parsers::Person do
  subject(:parser) { described_class.new }

  describe "#call" do
    it "answers record for valid content" do
      expect(parser.call("Jane Doe <jdoe@example.com>")).to eq(
        Gitt::Models::Person[
          name: "Jane Doe",
          delimiter: " ",
          email: "<jdoe@example.com>"
        ]
      )
    end

    it "answers record for partial content" do
      expect(parser.call("bogus")).to eq(Gitt::Models::Person[name: "bogus", delimiter: ""])
    end

    it "answers record for empty content" do
      expect(parser.call("")).to eq(Gitt::Models::Person[name: "", delimiter: ""])
    end
  end
end
