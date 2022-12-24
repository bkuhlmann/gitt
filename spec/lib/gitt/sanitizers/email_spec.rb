# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Email do
  subject(:sanitizer) { described_class }

  describe "#call" do
    it "answers email with no less than prefix or greater than suffix" do
      expect(sanitizer.call("<test@example.com>")).to eq("test@example.com")
    end

    it "answers nil if given nil" do
      expect(sanitizer.call(nil)).to be(nil)
    end
  end
end
