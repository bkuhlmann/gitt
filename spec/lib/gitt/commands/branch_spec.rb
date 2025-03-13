# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Commands::Branch do
  subject(:command) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathname

  describe "#default" do
    it "answers main branch when undefined" do
      git_repo_dir.change_dir do
        `git config --add init.defaultBranch ""`
        expect(command.default).to be_success("main")
      end
    end

    it "answers custom fallback when undefined" do
      git_repo_dir.change_dir do
        `git config --add init.defaultBranch ""`
        expect(command.default("other")).to be_success("other")
      end
    end

    it "answers main branch when failure" do
      shell = instance_double Gitt::Shell
      command = described_class.new(shell:)
      allow(shell).to receive(:call).with("config", "init.defaultBranch").and_return(Failure(""))

      expect(command.default).to be_success("main")
    end

    it "answers custom branch when defined" do
      git_repo_dir.change_dir do
        `git config --add init.defaultBranch "source"`
        expect(command.default).to be_success("source")
      end
    end
  end

  describe "#call" do
    it "answers main branch with default arguments" do
      expect(command.call(chdir: git_repo_dir.to_s)).to be_success("* main\n")
    end

    it "answers main branch with custom arguments" do
      expect(command.call("--list", chdir: git_repo_dir.to_s)).to be_success("* main\n")
    end
  end

  describe "#name" do
    it "answers default branch name" do
      expect(command.name(chdir: git_repo_dir.to_s)).to be_success("main")
    end

    it "answers feature branch name" do
      git_repo_dir.change_dir do
        `git switch --create example --track`
        expect(command.name).to be_success("example")
      end
    end

    it "answers failure when name can't be obtained" do
      git_repo_dir.rmtree.make_dir.change_dir do
        `git init`
        expect(command.name).to match(Failure(/fatal/))
      end
    end
  end
end
