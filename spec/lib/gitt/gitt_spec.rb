# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt do
  describe ".new" do
    it "answers responsitory instance" do
      expect(described_class.new).to be_a(Gitt::Repository)
    end
  end
end
