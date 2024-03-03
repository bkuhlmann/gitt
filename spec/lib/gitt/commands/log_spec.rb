  using Refinements::Pathname
    it "answers commit without scissors" do
      git_repo_dir.change_dir do
        path = SPEC_ROOT.join "support/fixtures/commit-verbose.txt"
        result = command.uncommitted path

        expect(result.success).to have_attributes(
          author_email: "test@example.com",
          author_name: "Test User",
          authored_relative_at: "0 seconds ago",
          body: "A fixture for a `git commit --verbose` commit.\n",
          body_lines: ["A fixture for a `git commit --verbose` commit."],
          body_paragraphs: ["A fixture for a `git commit --verbose` commit."],
          raw: "Added commit with verbose option\n\n" \
               "A fixture for a `git commit --verbose` commit.\n\n" \
               "# ------------------------ >8 ------------------------\n" \
               "# Do not modify or remove the line above.\n" \
               "# Everything below it will be ignored.\n" \
               "diff --git c/example.rb i/example.rb\n" \
               "new file mode 100644\n" \
               "index 000000000000..0e301c62c940\n" \
               "--- /dev/null\n" \
               "+++ i/example.rb\n" \
               "@@ -0,0 +1 @@\n" \
               "+def example = puts __method__\n",
          sha: /\A\h{40}\Z/,
          subject: "Added commit with verbose option",
          trailers: []
        )
      end
    end
