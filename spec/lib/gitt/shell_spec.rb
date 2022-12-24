# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Shell do
  subject(:shell) { described_class.new }

  describe "#call" do
    it "answers success" do
      expect(shell.call("--version")).to match(Success(/git version/))
    end

    it "answers failure" do
      expect(shell.call("bogus")).to match(Failure(/not a git command/))
    end
  end
end
