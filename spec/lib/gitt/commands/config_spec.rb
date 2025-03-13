# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Commands::Config do
  subject(:command) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathname

  let(:environment) { ENV }

  describe "#call" do
    it "answers attributes with default arguments" do
      result = command.call "--list", chdir: git_repo_dir.to_s
      expect(result).to match(Success(%r(core.hookspath=/dev/null)m))
    end

    it "answers error with invalid arguments" do
      result = command.call "--bogus", chdir: git_repo_dir.to_s
      expect(result).to match(Failure(/unknown option.+bogus.+/))
    end
  end

  describe "#get" do
    let(:key) { "user.name" }

    it "answers value without whitespace when key exists" do
      expect(command.get(key, chdir: git_repo_dir.to_s)).to be_success("Test User")
    end

    it "answers empty string when key doesn't exist" do
      expect(command.get("bogus")).to be_success("")
    end

    it "answers default value when key is invalid" do
      expect(command.get("bogus", "fallback")).to be_success("fallback")
    end

    it "yields error when when key is invalid" do
      command.get "bogus" do |error|
        expect(error).to eq("error: key does not contain a section: bogus\n")
      end
    end
  end

  describe "#origin?" do
    before { temp_dir.change_dir { `git init` } }

    it "answers true when remote repository is defined" do
      temp_dir.change_dir do
        `git config remote.origin.url git@github.com:test/example.git`
        expect(command.origin?).to be(true)
      end
    end

    it "answers false when remote repository is not defined" do
      temp_dir.change_dir { expect(command.origin?).to be(false) }
    end
  end

  describe "#set" do
    context "when key exists" do
      let(:key) { "user.name" }
      let(:value) { "Jayne Doe" }

      it "sets key with value" do
        command.set key, value, chdir: git_repo_dir.to_s
        expect(command.get(key, chdir: git_repo_dir.to_s)).to be_success(value)
      end

      it "answers value when key is successfully set" do
        expect(command.set(key, value, chdir: git_repo_dir.to_s)).to be_success(value)
      end
    end

    context "when key doesn't exist" do
      let(:key) { "user.test" }
      let(:value) { "example" }

      it "sets key with value" do
        command.set key, value, chdir: git_repo_dir.to_s
        expect(command.get(key, chdir: git_repo_dir.to_s)).to be_success(value)
      end

      it "answers value when key is successfully set" do
        expect(command.set(key, value, chdir: git_repo_dir.to_s)).to be_success("example")
      end
    end

    it "answers error when key is invalid" do
      expect(command.set("bogus", "invalid", chdir: git_repo_dir.to_s)).to match(Failure(/error/))
    end
  end
end
