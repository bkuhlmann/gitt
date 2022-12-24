# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Models::Person do
  subject(:person) { described_class.new }

  describe ".for" do
    it "answers record for content" do
      expect(described_class.for("Jane Doe <jdoe@example.com>")).to eq(
        described_class[name: "Jane Doe", delimiter: " ", email: "<jdoe@example.com>"]
      )
    end
  end

  describe "#initialize" do
    it "answers frozen instance" do
      expect(person.frozen?).to be(true)
    end
  end

  describe "#to_s" do
    subject :person do
      described_class[name: "Jane Doe", delimiter: " ", email: "<jdoe@example.com>"]
    end

    it "answers string with all attributes" do
      expect(person.to_s).to eq("Jane Doe <jdoe@example.com>")
    end

    it "answers string with partial attributes" do
      person = described_class[name: "Jane Doe", email: "<jdoe@example.com>"]
      expect(person.to_s).to eq("Jane Doe<jdoe@example.com>")
    end

    it "answers empty string with no attributes" do
      expect(described_class.new.to_s).to eq("")
    end
  end
end
