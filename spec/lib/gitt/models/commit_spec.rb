# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Models::Commit do
  subject(:comment) { described_class.new }

  describe "#initialize" do
    it "answers frozen instance" do
      expect(comment.frozen?).to be(true)
    end
  end

  describe "#amend?" do
    it "answers true when subject includes prefix" do
      expect(described_class[subject: "amend! Added test file"].amend?).to be(true)
    end

    it "answers false when subject excludes prefix" do
      expect(described_class[subject: "Added test file"].amend?).to be(false)
    end

    it "answers false when prefix is missing trailing space" do
      expect(described_class[subject: "amend!Added test file"].amend?).to be(false)
    end

    it "answers false when prefix has leading space" do
      expect(described_class[subject: " amend! Added test file"].amend?).to be(false)
    end
  end

  describe "#fixup?" do
    it "answers true when subject includes prefix" do
      expect(described_class[subject: "fixup! Added test file"].fixup?).to be(true)
    end

    it "answers false when subject excludes prefix" do
      expect(described_class[subject: "Added test file"].fixup?).to be(false)
    end

    it "answers false when prefix is missing trailing space" do
      expect(described_class[subject: "fixup!Added test file"].fixup?).to be(false)
    end

    it "answers false when prefix has leading space" do
      expect(described_class[subject: " fixup! Added test file"].fixup?).to be(false)
    end
  end

  describe "#squash?" do
    it "answers true when subject includes prefix" do
      expect(described_class[subject: "squash! Added test file"].squash?).to be(true)
    end

    it "answers false when subject excludes prefix" do
      expect(described_class[subject: "Added test file"].squash?).to be(false)
    end

    it "answers false when prefix is missing trailing space" do
      expect(described_class[subject: "squash!Added test file"].squash?).to be(false)
    end

    it "answers false when prefix has leading space" do
      expect(described_class[subject: " squash! Added test file"].squash?).to be(false)
    end
  end

  describe "#prefix?" do
    it "answers true when subject includes amend prefix" do
      expect(described_class[subject: "amend! Added test file"].prefix?).to be(true)
    end

    it "answers true when subject includes fixup prefix" do
      expect(described_class[subject: "fixup! Added test file"].prefix?).to be(true)
    end

    it "answers true when subject includes squash prefix" do
      expect(described_class[subject: "squash! Added test file"].prefix?).to be(true)
    end

    it "answers false when subject's prefix is normal" do
      expect(described_class[subject: "Added test file"].prefix?).to be(false)
    end
  end
end
