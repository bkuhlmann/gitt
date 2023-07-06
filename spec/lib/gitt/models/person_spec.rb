# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Models::Person do
  subject(:person) { described_class[name: "Jane Doe", email: "jdoe@example.com"] }

  describe ".for" do
    it "answers record for content" do
      expect(described_class.for("Jane Doe <jdoe@example.com>")).to eq(
        described_class[name: "Jane Doe", email: "jdoe@example.com"]
      )
    end
  end

  describe "#to_s" do
    it "answers string with name, delimiter, and email" do
      expect(person.to_s).to eq("Jane Doe <jdoe@example.com>")
    end

    it "answers string with name only" do
      expect(person.with(email: nil).to_s).to eq("Jane Doe")
    end

    it "answers string with email only" do
      expect(person.with(name: nil).to_s).to eq("<jdoe@example.com>")
    end

    it "answers string with custom delimiter" do
      expect(person.with(delimiter: "").to_s).to eq("Jane Doe<jdoe@example.com>")
    end

    it "answers empty string with nil attributes" do
      expect(described_class[name: nil, delimiter: nil, email: nil].to_s).to eq("")
    end

    it "answers empty string with defaults only" do
      expect(described_class.new.to_s).to eq("")
    end
  end
end
