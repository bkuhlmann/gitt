# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Models::Tag do
  subject(:tag) { described_class.new }

  describe "#initialize" do
    it "answers frozen instance" do
      expect(tag.frozen?).to be(true)
    end
  end
end
