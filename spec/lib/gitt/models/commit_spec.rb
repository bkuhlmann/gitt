# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Models::Commit do
  subject(:commit) { described_class.new }

  describe "#initialize" do
    it "answers frozen instance" do
      expect(commit.frozen?).to be(true)
    end
  end

  context "with directives" do
    subject(:directable) { described_class.new.dup }

    it_behaves_like "a directable"
  end

  context "with trailers" do
    subject(:trailable) { described_class[trailers:] }

    it_behaves_like "a trailable"
  end
end
