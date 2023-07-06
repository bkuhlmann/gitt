# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Parsers::Person do
  subject(:parser) { described_class.new }

  describe "#call" do
    it "answers record for valid content" do
      expect(parser.call("Jane Doe <jdoe@example.com>")).to eq(
        Gitt::Models::Person[
          name: "Jane Doe",
          email: "jdoe@example.com"
        ]
      )
    end

    it "answers record for first name only" do
      expect(parser.call("Jane")).to eq(Gitt::Models::Person[name: "Jane"])
    end

    it "answers record for full name only" do
      expect(parser.call("Jane Doe")).to eq(Gitt::Models::Person[name: "Jane Doe"])
    end

    it "answers record for email only" do
      expect(parser.call("<jdoe@example.com>")).to eq(
        Gitt::Models::Person[email: "jdoe@example.com"]
      )
    end

    it "answers empty record for empty content" do
      expect(parser.call("")).to eq(Gitt::Models::Person.new)
    end
  end
end
