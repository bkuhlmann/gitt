# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Commands::Tag do
  subject(:command) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathnames

  shared_examples "a tag" do |method|
    it "fails when there is no version" do
      result = command.public_send method, nil
      expect(result).to eq(Failure("Unable to create Git tag without version."))
    end

    it "prints warning when tag exists" do
      git_repo_dir.change_dir do
        `git tag 0.0.0`
        result = command.public_send method, "0.0.0"

        expect(result).to eq(Failure("Tag exists: 0.0.0."))
      end
    end
  end

  describe "#call" do
    it "answers empty string with custom arguments" do
      git_repo_dir.change_dir { expect(command.call("--list")).to eq(Success("")) }
    end
  end

  describe "#create" do
    it_behaves_like "a tag", :create

    it "creates versioned tag" do
      git_repo_dir.change_dir do
        command.create "1.2.3"
        expect(`git show --stat --pretty=format:"%b" "1.2.3"`).to match(/tag 1.2.3/m)
      end
    end

    it "answer version" do
      git_repo_dir.change_dir { expect(command.create("1.2.3")).to eq(Success("1.2.3")) }
    end

    it "fails when tag can't be created" do
      git_repo_dir.remove_tree.make_dir.change_dir do
        `git init`
        expect(command.create("1.2.3")).to eq(Failure("Unable to create tag: 1.2.3."))
      end
    end
  end

  describe "#exist?" do
    it "answers true when only local tag exists" do
      git_repo_dir.change_dir do
        `git tag 1.2.3`
        expect(command.exist?("1.2.3")).to be(true)
      end
    end

    it "answers true when only remote tag exists" do
      git_repo_dir.change_dir { expect(command.exist?("0.0.0")).to be(true) }
    end

    it "answers false when local and remote tags don't exist" do
      git_repo_dir.change_dir { expect(command.exist?("1.2.3")).to be(false) }
    end
  end

  describe "#index" do
    it "answers record" do
      git_repo_dir.change_dir do
        `git tag --message "Version 0.0.0" --message "Test." 0.0.0`
        records = command.index.success.map(&:to_h)

        expect(records).to contain_exactly(
          hash_including(
            author_email: "test@example.com",
            author_name: "Test User",
            authored_at: /\d{10}/,
            authored_relative_at: /\A\d+ seconds?? ago\Z/,
            body: "Test.\n",
            committed_at: /\d{10}/,
            committed_relative_at: /\A\d+ seconds?? ago\Z/,
            committer_email: "test@example.com",
            committer_name: "Test User",
            sha: /\h{40}/,
            subject: "Version 0.0.0",
            version: "0.0.0"
          )
        )
      end
    end
  end

  describe "#last" do
    it "answers last tag when tag exists" do
      git_repo_dir.change_dir do
        `touch test.txt && git add . && git commit --message "Added test file" && git tag 0.1.0`
        expect(command.last).to eq(Success("0.1.0"))
      end
    end

    it "answers failure when no tags exist" do
      git_repo_dir.change_dir { expect(command.last).to eq(Failure("No tags found.")) }
    end

    it "answers failure when last tag can't be obtained" do
      shell = instance_double Gitt::Shell, call: Failure("fatal: Danger!")
      command = described_class.new(shell:)

      expect(command.last).to eq(Failure("Danger!"))
    end
  end

  describe "#local?" do
    it "answers true with matching tag" do
      git_repo_dir.change_dir do
        `git tag 0.1.0`
        expect(command.local?("0.1.0")).to be(true)
      end
    end

    it "answers false with non-existant tag" do
      git_repo_dir.change_dir do
        `git tag 0.0.0`
        expect(command.local?("0.1.0")).to be(false)
      end
    end

    it "answers false with no tags" do
      git_repo_dir.change_dir { expect(command.local?("0.1.0")).to be(false) }
    end
  end

  describe "#push" do
    subject(:command) { described_class.new shell: }

    let(:shell) { Gitt::Shell.new client: }
    let(:client) { class_spy Open3, capture3: [nil, nil, status] }
    let(:status) { instance_spy Process::Status, success?: true }

    it "pushes tags" do
      git_repo_dir.change_dir do
        `git tag 0.1.0`
        command.push

        expect(client).to have_received(:capture3).with("git", "push", "--tags")
      end
    end
  end

  describe "#remote?" do
    subject(:command) { described_class.new shell: }

    let(:shell) { Gitt::Shell.new client: }
    let(:client) { class_spy Open3, capture3: ["refs/tags/0.1.0", "", status] }
    let(:status) { instance_spy Process::Status, success?: true }

    it "answers true when tag exists" do
      git_repo_dir.change_dir { expect(command.remote?("0.1.0")).to be(true) }
    end

    it "answers false when tag doesn't exist" do
      git_repo_dir.change_dir { expect(command.remote?("0.2.0")).to be(false) }
    end
  end

  describe "#show" do
    it "answers record" do
      git_repo_dir.change_dir do
        `git tag --message "Version 0.0.0" --message "Test." 0.0.0`

        expect(command.show("0.0.0").success).to have_attributes(
          author_email: "test@example.com",
          author_name: "Test User",
          authored_at: /\d{10}/,
          authored_relative_at: "0 seconds ago",
          body: "Test.\n",
          committed_at: /\d{10}/,
          committed_relative_at: "0 seconds ago",
          committer_email: "test@example.com",
          committer_name: "Test User",
          sha: /\h{40}/,
          subject: "Version 0.0.0",
          version: "0.0.0"
        )
      end
    end
  end

  describe "#tagged?" do
    it "answers true when tags exist" do
      git_repo_dir.change_dir do
        `git tag 0.1.0`
        expect(command.tagged?).to be(true)
      end
    end

    it "answers false when tags don't exist" do
      git_repo_dir.change_dir { expect(command.tagged?).to be(false) }
    end
  end
end
