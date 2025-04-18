# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Repository do
  subject(:repository) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathname

  describe "#branch" do
    it "answers main branch" do
      expect(repository.branch(chdir: git_repo_dir.to_s)).to be_success("* main\n")
    end
  end

  describe "#branch_default" do
    it "answers branch default" do
      expect(repository.branch_default(chdir: git_repo_dir.to_s)).to be_success("main")
    end

    it "answers branch fallback" do
      git_repo_dir.change_dir do
        `git config --add init.defaultBranch ""`
        expect(repository.branch_default("other")).to be_success("other")
      end
    end
  end

  describe "#branch_name" do
    it "answers branch name" do
      expect(repository.branch_name(chdir: git_repo_dir.to_s)).to be_success("main")
    end
  end

  describe "#call" do
    it "answers" do
      expect(repository.call("--man-path", chdir: git_repo_dir.to_s)).to match(Success(String))
    end
  end

  describe "#commits" do
    let :proof do
      hash_including(
        author_email: "test@example.com",
        author_name: "Test User",
        authored_at: /\d{10}/,
        authored_relative_at: /\A\d+ seconds?? ago\Z/,
        body: "",
        body_lines: [],
        body_paragraphs: [],
        committed_at: /\d{10}/,
        committed_relative_at: /\A\d+ seconds?? ago\Z/,
        committer_email: "test@example.com",
        committer_name: "Test User",
        raw: "Added documentation\n",
        sha: /\A[0-9a-f]{40}\Z/,
        signature: "None",
        subject: "Added documentation",
        trailers: []
      )
    end

    it "answers saved commit" do
      commits = repository.commits(chdir: git_repo_dir.to_s).success.map(&:to_h)
      expect(commits).to contain_exactly(proof)
    end
  end

  describe "#config" do
    it "answers missing configuration" do
      expect(repository.config(chdir: git_repo_dir.to_s)).to match(Failure(/no action specified/))
    end
  end

  describe "#exist?" do
    it "answers true when repository exists" do
      git_repo_dir.change_dir { expect(repository.exist?).to be(true) }
    end

    it "answers false when repository doesn't exist" do
      temp_dir.change_dir { expect(repository.exist?).to be(false) }
    end
  end

  describe "#get" do
    let(:key) { "user.name" }

    it "answers value" do
      expect(repository.get(key, chdir: git_repo_dir.to_s)).to be_success("Test User")
    end
  end

  describe "#inspect" do
    it "answers something" do
      expect(repository.inspect).to match(/\#<Gitt::Repository:\d+\s@shell=.+\s@commands=\[.+\]>/xo)
    end
  end

  describe "#log" do
    it "answers commit log/history" do
      expect(repository.log(chdir: git_repo_dir.to_s)).to match(Success(/Added documentation/))
    end
  end

  describe "#origin?" do
    it "answers false when remote repository isn't defined" do
      git_repo_dir.change_dir { expect(repository.origin?).to be(true) }
    end
  end

  describe "#set" do
    it "sets key with value" do
      key = "user.name"
      value = "Jayne Doe"

      git_repo_dir.change_dir do
        repository.set key, value
        expect(repository.get(key)).to be_success(value)
      end
    end
  end

  describe "#tag" do
    it "delegates to tag command" do
      expect(repository.tag(chdir: git_repo_dir.to_s)).to be_success("")
    end
  end

  describe "#tags" do
    it "answers record" do
      git_repo_dir.change_dir do
        `git tag --message "Version 0.0.0" --message "Test." 0.0.0`
        records = repository.tags.success.map(&:to_h)

        expect(records).to contain_exactly(
          hash_including(
            author_email: "test@example.com",
            author_name: "Test User",
            authored_at: /\d{10}/,
            authored_relative_at: /\A\d+ seconds?? ago\Z/,
            body: "Test.",
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

  describe "#tag?" do
    it "answers if tag exists" do
      expect(repository.tag?("1.2.3")).to be(false)
    end
  end

  describe "#tag_create" do
    it "creates tag with version infomration" do
      git_repo_dir.change_dir do
        repository.tag_create "0.1.0", "Test."
        expect(repository.tag_last).to be_success("0.1.0")
      end
    end
  end

  describe "#tag_delete_local" do
    it "deletes tag" do
      path = git_repo_dir.to_s
      result = repository.call("tag", "0.0.0", chdir: path)
                         .bind { repository.tag_delete_local "0.0.0", chdir: path }

      expect(result).to be_success("0.0.0")
    end
  end

  describe "#tag_delete_remote" do
    it "deletes tag" do
      repository = described_class.new shell: instance_double(Gitt::Shell, call: Success(""))
      expect(repository.tag_delete_remote("0.0.0")).to be_success("0.0.0")
    end
  end

  describe "#tag_last" do
    it "answers last tag" do
      git_repo_dir.change_dir do
        `git tag 0.0.0`
        expect(repository.tag_last).to be_success("0.0.0")
      end
    end
  end

  describe "#tag_local?" do
    it "answers if tag is local" do
      expect(repository.tag_local?("1.2.3")).to be(false)
    end
  end

  describe "#tag_remote?" do
    it "answers if tag is remote" do
      expect(repository.tag_remote?("1.2.3")).to be(false)
    end
  end

  describe "#tag_show" do
    it "answers tag record" do
      git_repo_dir.change_dir do
        repository.tag_create "0.1.0"
        expect(repository.tag_show("--list").success).to be_a(Gitt::Models::Tag)
      end
    end
  end

  describe "#tagged?" do
    it "answers if tagged" do
      git_repo_dir.change_dir { expect(repository.tagged?).to be(false) }
    end
  end

  describe "tags_push" do
    subject(:repository) { described_class.new shell: }

    let(:shell) { Gitt::Shell.new client: }
    let(:client) { class_spy Open3, capture3: [nil, nil, status] }
    let(:status) { instance_double Process::Status, success?: true }

    it "pushes tags" do
      git_repo_dir.change_dir do
        repository.tags_push
        expect(client).to have_received(:capture3).with("git", "push", "--tags")
      end
    end
  end

  describe "#uncommitted" do
    it "answers unsaved commit" do
      path = temp_dir.join("test.txt").write "Added documentation"

      git_repo_dir.change_dir do
        expect(repository.uncommitted(path).success.to_h).to match(
          author_email: "test@example.com",
          author_name: "Test User",
          authored_at: /\d{10}/,
          authored_relative_at: "0 seconds ago",
          body: "",
          body_lines: [],
          body_paragraphs: [],
          committed_at: /\d{10}/,
          committed_relative_at: "0 seconds ago",
          committer_email: "test@example.com",
          committer_name: "Test User",
          deletions: 0,
          encoding: "",
          files_changed: 0,
          fingerprint: "",
          fingerprint_key: "",
          insertions: 0,
          lines: ["Added documentation"],
          notes: "",
          raw: "Added documentation",
          sha: /\A[0-9a-f]{40}\Z/,
          signature: "None",
          subject: "Added documentation",
          trailers: []
        )
      end
    end
  end
end
