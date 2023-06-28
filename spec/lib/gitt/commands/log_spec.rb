# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Commands::Log do
  subject(:command) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathnames

  describe "#call" do
    it "answers log with default arguments" do
      git_repo_dir.change_dir { expect(command.call).to match(Success(/Added documentation/)) }
    end

    it "answers log with custom arguments" do
      git_repo_dir.change_dir do
        expect(command.call("-1")).to match(Success(/Added documentation/))
      end
    end

    it "answers error with invalid arguments" do
      git_repo_dir.change_dir { expect(command.call("--bogus")).to match(Failure(/bogus/)) }
    end
  end

  describe "#index" do
    let :proof do
      hash_including(
        author_email: "test@example.com",
        author_name: "Test User",
        authored_relative_at: /\A\d+ seconds?? ago\Z/,
        body: "",
        body_lines: [],
        body_paragraphs: [],
        deletions: 0,
        files_changed: 1,
        insertions: 0,
        raw: "Added documentation\n",
        sha: /\A[0-9a-f]{40}\Z/,
        subject: "Added documentation",
        trailers: []
      )
    end

    it "answers commits with range only" do
      git_repo_dir.change_dir do
        commits = command.index("-1").success.map(&:to_h)
        expect(commits).to contain_exactly(proof)
      end
    end

    it "answers commits with flags only" do
      git_repo_dir.change_dir do
        commits = command.index("--author", "Test User").success.map(&:to_h)
        expect(commits).to contain_exactly(proof)
      end
    end

    it "answers commits with range and flags" do
      git_repo_dir.change_dir do
        commits = command.index("--author", "Test User", "-1").success.map(&:to_h)
        expect(commits).to contain_exactly(proof)
      end
    end

    it "answers commits with subject only" do
      git_repo_dir.change_dir do
        commits = command.index.success.map(&:to_h)
        expect(commits).to contain_exactly(proof)
      end
    end

    it "answers commits with subject and single-line body" do
      message = <<~CONTENT
        Added test

        One.
      CONTENT

      git_repo_dir.change_dir do
        `git commit --amend --message '#{message}'`
        commits = command.index.success.map(&:to_h)

        expect(commits).to contain_exactly(
          hash_including(
            author_email: "test@example.com",
            author_name: "Test User",
            authored_relative_at: /\A\d+ seconds?? ago\Z/,
            body: "One.",
            body_lines: ["One."],
            body_paragraphs: ["One."],
            raw: "Added test\n\nOne.\n",
            sha: /\A[0-9a-f]{40}\Z/,
            subject: "Added test",
            trailers: []
          )
        )
      end
    end

    it "answers commits with subject, body, and trailers" do
      message = <<~CONTENT
        Added test

        One.

        One: 1
        Two: 2
      CONTENT

      git_repo_dir.change_dir do
        `git commit --amend --message '#{message}'`
        commits = command.index.success.map(&:to_h)

        expect(commits).to contain_exactly(
          hash_including(
            author_email: "test@example.com",
            author_name: "Test User",
            authored_relative_at: /\A\d+ seconds?? ago\Z/,
            body: "One.",
            body_lines: ["One."],
            body_paragraphs: ["One."],
            raw: "Added test\n\nOne.\n\nOne: 1\nTwo: 2\n",
            sha: /\A[0-9a-f]{40}\Z/,
            subject: "Added test",
            trailers: [
              Gitt::Models::Trailer[key: "One", value: "1"],
              Gitt::Models::Trailer[key: "Two", value: "2"]
            ]
          )
        )
      end
    end

    it "answers commits with subject, body, trailers, and intermixed comments" do
      message = <<~CONTENT
        Added test

        # One.

        One.

        # Two.

        One: 1

        # Three.
      CONTENT

      git_repo_dir.change_dir do
        `git commit --amend --message '#{message}'`
        commits = command.index.success.first

        expect(commits).to have_attributes(
          author_email: "test@example.com",
          author_name: "Test User",
          authored_relative_at: /\A\d+ seconds?? ago\Z/,
          body: "# One.\n\nOne.\n\n# Two.\n\n# Three.",
          body_lines: ["# One.", "", "One.", "", "# Two.", "", "# Three."],
          body_paragraphs: ["# One.", "One.", "# Two.", "# Three."],
          raw: "Added test\n\n# One.\n\nOne.\n\n# Two.\n\nOne: 1\n\n# Three.\n",
          sha: /\A[0-9a-f]{40}\Z/,
          subject: "Added test",
          trailers: [
            Gitt::Models::Trailer[key: "One", value: "1"]
          ]
        )
      end
    end

    it "answers commits with invalid encoding replaced with question marks" do
      git_repo_dir.change_dir do
        `git config i18n.commitEncoding Shift_JIS`
        `git commit --amend --message "Added \210\221\332\332\337\341\341"`
        commits = command.index.success.map(&:to_h)

        expect(commits).to contain_exactly(
          hash_including(
            author_email: "test@example.com",
            author_name: "Test User",
            authored_relative_at: /\A\d+ seconds?? ago\Z/,
            body: "",
            body_lines: [],
            body_paragraphs: [],
            raw: "Added ???????\n",
            sha: /\A[0-9a-f]{40}\Z/,
            subject: "Added ???????",
            trailers: []
          )
        )
      end
    end

    it "answers updated statistics with file changes" do
      git_repo_dir.change_dir do
        `echo "Test." > README.md && git commit --amend --all --no-edit`
        commit = command.index.success.map(&:to_h)

        expect(commit).to contain_exactly(
          hash_including(files_changed: 1, insertions: 1, deletions: 0)
        )
      end
    end

    context "with multiple commits" do
      let :proof_one do
        hash_including(
          author_email: "test@example.com",
          author_name: "Test User",
          authored_relative_at: /\A\d+ seconds?? ago\Z/,
          body: "",
          body_lines: [],
          body_paragraphs: [],
          raw: "Added documentation\n",
          sha: /\A[0-9a-f]{40}\Z/,
          signature: "None",
          subject: "Added documentation",
          trailers: []
        )
      end

      let :proof_two do
        hash_including(
          author_email: "test@example.com",
          author_name: "Test User",
          authored_relative_at: /\A\d+ seconds?? ago\Z/,
          body: "",
          body_lines: [],
          body_paragraphs: [],
          raw: "Added documentation\n",
          sha: /\A[0-9a-f]{40}\Z/,
          signature: "None",
          subject: "Added documentation",
          trailers: []
        )
      end

      it "answers commits" do
        git_repo_dir.change_dir do
          `touch test.txt && git add --all && git commit --message "Added documentation"`
          commits = command.index.success.map(&:to_h)

          expect(commits).to contain_exactly(proof_one, proof_two)
        end
      end
    end

    it "answers zero stats for empty commits" do
      git_repo_dir.change_dir do
        `git commit --allow-empty --message "----- Breakpoint -----"`
        commits = command.index.success.map(&:to_h)

        expect(commits.last).to match(
          hash_including(
            subject: "----- Breakpoint -----",
            deletions: 0,
            files_changed: 0,
            insertions: 0
          )
        )
      end
    end

    it "answers error with invalid argument" do
      git_repo_dir.change_dir { expect(command.index("bogus")).to match(Failure(/bogus/)) }
    end
  end

  describe "#uncommitted" do
    it "answers single commit" do
      git_repo_dir.change_dir do
        path = SPEC_ROOT.join "support/fixtures/commit-valid.txt"
        result = command.uncommitted path

        expect(result.success).to have_attributes(
          author_email: "test@example.com",
          author_name: "Test User",
          authored_relative_at: "0 seconds ago",
          body: "An example paragraph.\n\n" \
                "A bullet list:\n  - One.\n\n" \
                "# A comment block.",
          body_lines: [
            "An example paragraph.",
            "",
            "A bullet list:",
            "  - One.",
            "",
            "# A comment block."
          ],
          body_paragraphs: [
            "An example paragraph.",
            "A bullet list:\n  - One.",
            "# A comment block."
          ],
          raw: "Added example\n\n" \
               "An example paragraph.\n\n" \
               "A bullet list:\n  - One.\n\n" \
               "# A comment block.\n\n" \
               "One: 1\nTwo: 2\n",
          sha: /\A\h{40}\Z/,
          subject: "Added example",
          trailers: [
            Gitt::Models::Trailer[key: "One", value: "1"],
            Gitt::Models::Trailer[key: "Two", value: "2"]
          ]
        )
      end
    end

    it "answers error with invalid path" do
      path = Bundler.root.join "tmp/bogus.txt"
      expect(command.uncommitted(path)).to eq(Failure(%(Invalid commit message path: "#{path}".)))
    end
  end
end
