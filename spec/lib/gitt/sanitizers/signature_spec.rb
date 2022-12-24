# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Signature do
  subject(:sanitizer) { described_class }

  describe "#call" do
    it "answers bad" do
      expect(sanitizer.call("B")).to eq("Bad")
    end

    it "answers error" do
      expect(sanitizer.call("E")).to eq("Error")
    end

    it "answers good" do
      expect(sanitizer.call("G")).to eq("Good")
    end

    it "answers none" do
      expect(sanitizer.call("N")).to eq("None")
    end

    it "answers revoked" do
      expect(sanitizer.call("R")).to eq("Revoked")
    end

    it "answers unknown" do
      expect(sanitizer.call("U")).to eq("Unknown")
    end

    it "answers expired" do
      expect(sanitizer.call("X")).to eq("Expired")
    end

    it "answers expired key" do
      expect(sanitizer.call("Y")).to eq("Expired Key")
    end

    it "answers invalid with unknown code" do
      expect(sanitizer.call("bogus")).to eq("Invalid")
    end
  end
end
