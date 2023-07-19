# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Models::Commit do
  subject(:comment) { described_class.new }

  describe "#initialize" do
    it "answers frozen instance" do
      expect(comment.frozen?).to be(true)
    end
  end
end
