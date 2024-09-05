# frozen_string_literal: true

RSpec.shared_examples "a directable" do
  describe "#directive?" do
    it "answers true when subject starts with directive" do
      directable.subject = "amend! Added test file"
      expect(directable.directive?).to be(true)
    end

    it "answers true when subject starts with fixup directive" do
      directable.subject = "fixup! Added test file"
      expect(directable.directive?).to be(true)
    end

    it "answers true when subject starts with squash directive" do
      directable.subject = "squash! Added test file"
      expect(directable.directive?).to be(true)
    end

    it "answers false when subject starts with normal prefix" do
      directable.subject = "Added test file"
      expect(directable.directive?).to be(false)
    end
  end

  describe "#amend?" do
    it "answers true when subject starts with directive" do
      directable.subject = "amend! Added test file"
      expect(directable.amend?).to be(true)
    end

    it "answers false when subject doesn't start with directive" do
      directable.subject = "Added test file"
      expect(directable.amend?).to be(false)
    end

    it "answers false when directive is missing trailing space" do
      directable.subject = "amend!Added test file"
      expect(directable.amend?).to be(false)
    end

    it "answers false when directive has leading space" do
      directable.subject = " amend! Added test file"
      expect(directable.amend?).to be(false)
    end
  end

  describe "#fixup?" do
    it "answers true when subject starts with directive" do
      directable.subject = "fixup! Added test file"
      expect(directable.fixup?).to be(true)
    end

    it "answers false when subject doesn't start with directive" do
      directable.subject = "Added test file"
      expect(directable.fixup?).to be(false)
    end

    it "answers false when directive is missing trailing space" do
      directable.subject = "fixup!Added test file"
      expect(directable.fixup?).to be(false)
    end

    it "answers false when directive has leading space" do
      directable.subject = " fixup! Added test file"
      expect(directable.fixup?).to be(false)
    end
  end

  describe "#squash?" do
    it "answers true when subject starts with directive" do
      directable.subject = "squash! Added test file"
      expect(directable.squash?).to be(true)
    end

    it "answers false when subject doesn't start with directive" do
      directable.subject = "Added test file"
      expect(directable.squash?).to be(false)
    end

    it "answers false when directive is missing trailing space" do
      directable.subject = "squash!Added test file"
      expect(directable.squash?).to be(false)
    end

    it "answers false when directive has leading space" do
      directable.subject = " squash! Added test file"
      expect(directable.squash?).to be(false)
    end
  end

  describe "#prefix" do
    it "answers prefix when normal" do
      directable.subject = "Added test file"
      expect(directable.prefix).to eq("Added")
    end

    it "answers directive when using rebase directive" do
      directable.subject = "fixup! Added test file"
      expect(directable.prefix).to eq("fixup!")
    end

    it "answers prefix when followed by special character" do
      directable.subject = "fix: Test file"
      expect(directable.prefix).to eq("fix")
    end

    it "answers nil with special characters only" do
      directable.subject = "----- breakpoint -----"
      expect(directable.prefix).to be(nil)
    end
  end
end
