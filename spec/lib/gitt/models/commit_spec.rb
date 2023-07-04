# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Models::Commit do
  include Dry::Monads[:result]

  subject(:commit) { described_class.new }

  describe "#initialize" do
    it "answers frozen instance" do
      expect(commit.frozen?).to be(true)
    end
  end

  describe "#find_trailer" do
    subject(:commit) { described_class[trailers: [trailer]] }

    let(:trailer) { Gitt::Models::Trailer[key: "issue", value: "123"] }

    it "answers trailer for matching key" do
      expect(commit.find_trailer("issue")).to eq(Success(trailer))
    end

    it "answers failure when key isn't found" do
      expect(commit.find_trailer("format")).to eq(
        Failure(%(Unable to find trailer for key: "format".))
      )
    end
  end

  describe "#find_trailers" do
    subject(:commit) { described_class[trailers:] }

    let :trailers do
      [
        Gitt::Models::Trailer[key: "issue", value: "111"],
        Gitt::Models::Trailer[key: "format", value: "asciidoc"],
        Gitt::Models::Trailer[key: "issue", value: "222"]
      ]
    end

    it "answers array for matching key" do
      expect(commit.find_trailers("issue")).to eq(
        Success(
          [
            Gitt::Models::Trailer[key: "issue", value: "111"],
            Gitt::Models::Trailer[key: "issue", value: "222"]
          ]
        )
      )
    end

    it "answers empty array when key isn't found" do
      expect(commit.find_trailers("unknown")).to eq(Success([]))
    end
  end

  describe "#trailer_value_for" do
    subject(:commit) { described_class[trailers: [trailer]] }

    let(:trailer) { Gitt::Models::Trailer[key: "issue", value: "123"] }

    it "answers trailer for matching key" do
      expect(commit.trailer_value_for("issue")).to eq(Success("123"))
    end

    it "answers failure when key isn't found" do
      expect(commit.trailer_value_for("format")).to eq(
        Failure(%(Unable to find trailer for key: "format".))
      )
    end
  end

  describe "#trailer_values_for" do
    subject(:commit) { described_class[trailers:] }

    let :trailers do
      [
        Gitt::Models::Trailer[key: "issue", value: "111"],
        Gitt::Models::Trailer[key: "format", value: "asciidoc"],
        Gitt::Models::Trailer[key: "issue", value: "222"]
      ]
    end

    it "answers array for matching key" do
      expect(commit.trailer_values_for("issue")).to eq(Success(%w[111 222]))
    end

    it "answers empty array when key isn't found" do
      expect(commit.trailer_values_for("unknown")).to eq(Success([]))
    end
  end
end
