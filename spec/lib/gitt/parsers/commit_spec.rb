# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Parsers::Commit do
  using Refinements::Struct

  subject(:parser) { described_class.new }

  let :content do
    <<~CONTENT
      <author_email>test@example.com</author_email>
      <author_name>Test User</author_name>
      <authored_at>1668978801</authored_at>
      <authored_relative_at>0 seconds ago</authored_relative_at>
      <body></body>
      <committed_at>1668978801</committed_at>
      <committed_relative_at>1 second ago</committed_relative_at>
      <committer_email>other@example.com</committer_email>
      <committer_name>Other User</committer_name>
      <raw></raw>
      <sha>180dec7d8ae8cbe3565a727c63c2111e49e0b737</sha>
      <signature>N</signature>
      <subject>Added documentation</subject>
      <trailers></trailers>
    CONTENT
  end

  let :commit do
    Gitt::Models::Commit[
      author_email: "test@example.com",
      author_name: "Test User",
      authored_at: "1668978801",
      authored_relative_at: "0 seconds ago",
      body: "",
      body_lines: [],
      body_paragraphs: [],
      committed_at: "1668978801",
      committed_relative_at: "1 second ago",
      committer_email: "other@example.com",
      committer_name: "Other User",
      deletions: 0,
      files_changed: 0,
      insertions: 0,
      lines: [],
      raw: "",
      sha: "180dec7d8ae8cbe3565a727c63c2111e49e0b737",
      signature: "None",
      subject: "Added documentation",
      trailers: []
    ]
  end

  describe "#call" do
    it "answers without body" do
      expect(parser.call(content)).to eq(commit)
    end

    it "answers body lines and paragraphs with single body line" do
      expect(parser.call("<body>Test.\n</body>")).to have_attributes(
        body: "Test.",
        body_lines: ["Test."],
        body_paragraphs: ["Test."]
      )
    end

    it "answers body lines and paragraphs with multiple body lines" do
      expect(parser.call("<body>One.\nTwo.\nThree.\n</body>")).to have_attributes(
        body: "One.\nTwo.\nThree.",
        body_lines: ["One.", "Two.", "Three."],
        body_paragraphs: ["One.\nTwo.\nThree."]
      )
    end

    it "answers body lines and paragraphs with embedded comments" do
      expect(parser.call("<body>One.\n# Test.\nTwo.\n\nThree.\n</body>")).to have_attributes(
        body: "One.\n# Test.\nTwo.\n\nThree.",
        body_lines: ["One.", "# Test.", "Two.", "", "Three."],
        body_paragraphs: ["One.\n# Test.\nTwo.", "Three."]
      )
    end

    it "answers body lines and paragraphs with paragraphs" do
      expect(parser.call("<body>One.\n\nTwo.\n\nThree.\n</body>")).to have_attributes(
        body: "One.\n\nTwo.\n\nThree.",
        body_lines: ["One.", "", "Two.", "", "Three."],
        body_paragraphs: ["One.", "Two.", "Three."]
      )
    end

    it "answers body lines and paragraphs with multiple paragraphs" do
      body = "One A.\nOne B.\n\nTwo A.\nTwo B.\n\nThree."

      expect(parser.call("<body>#{body}</body>")).to have_attributes(
        body:,
        body_lines: [
          "One A.",
          "One B.",
          "",
          "Two A.",
          "Two B.",
          "",
          "Three."
        ],
        body_paragraphs: ["One A.\nOne B.", "Two A.\nTwo B.", "Three."]
      )
    end

    it "answers empty body lines and paragraphs with commented paragraphs only" do
      body = "# One.\n\n# Two.\n\n# Three."

      expect(parser.call("<body>#{body}</body>")).to have_attributes(
        body:,
        body_lines: ["# One.", "", "# Two.", "", "# Three."],
        body_paragraphs: ["# One.", "# Two.", "# Three."]
      )
    end

    it "answers body lines and paragraphs with mixed paragraphs of comments and text" do
      body = "One.\n\n# Two A.\n# Two B.\n\nThree."

      expect(parser.call("<body>#{body}</body>")).to have_attributes(
        body:,
        body_lines: ["One.", "", "# Two A.", "# Two B.", "", "Three."],
        body_paragraphs: ["One.", "# Two A.\n# Two B.", "Three."]
      )
    end

    it "answers body lines, paragraphs, and trailers" do
      content = <<~CONTENT
        <body>One.\n\none: 1\ntwo: 2\n</body>
        <trailers>one: 1\ntwo: 2\n</trailers>
      CONTENT

      expect(parser.call(content)).to have_attributes(
        body: "One.",
        body_lines: ["One."],
        body_paragraphs: ["One."],
        trailers: [
          Gitt::Models::Trailer[key: "one", value: "1"],
          Gitt::Models::Trailer[key: "two", value: "2"]
        ]
      )
    end

    it "answers body lines and paragraphs with trailers and suffixed comments" do
      content = <<~CONTENT
        <body>One.\n\none: 1\n\n# One.\n\n# Two.\n</body>
        <trailers>one: 1\n</trailers>
      CONTENT

      expect(parser.call(content)).to have_attributes(
        body: "One.\n\n# One.\n\n# Two.",
        body_lines: ["One.", "", "# One.", "", "# Two."],
        body_paragraphs: ["One.", "# One.", "# Two."],
        trailers: [
          Gitt::Models::Trailer[key: "one", value: "1"]
        ]
      )
    end

    it "answers trailers with special characters" do
      content = <<~CONTENT
        <body>One.\n\na: #!+\nissue: [x-1]\n</body>
        <trailers>a: #!+\nissue: [x-1]\n</trailers>
      CONTENT

      expect(parser.call(content)).to have_attributes(
        body: "One.",
        body_lines: ["One."],
        body_paragraphs: ["One."],
        trailers: [
          Gitt::Models::Trailer[key: "a", value: "#!+"],
          Gitt::Models::Trailer[key: "issue", value: "[x-1]"]
        ]
      )
    end

    it "answers with scissors for lines and raw attributes only" do
      content = <<~CONTENT
        <body>A test.\n\n# ----- >8 -----\n# Do not modify.</body>
        <raw>A test.\n\n# ----- >8 -----\n# Do not modify.</raw>
      CONTENT

      expect(parser.call(content)).to eq(
        Gitt::Models::Commit[
          body: "A test.\n",
          body_lines: ["A test."],
          body_paragraphs: ["A test."],
          deletions: 0,
          files_changed: 0,
          insertions: 0,
          lines: ["A test.", "", "# ----- >8 -----", "# Do not modify."],
          raw: "A test.\n\n# ----- >8 -----\n# Do not modify.",
          signature: "Invalid",
          trailers: []
        ]
      )
    end

    it "answers statistics" do
      content_with_stats = "#{content}\n" \
                           "<statistics>2 files updated, 5 insertions, 10 deletions</statistics>"
      proof = commit.merge deletions: 10, files_changed: 2, insertions: 5

      expect(parser.call(content_with_stats)).to eq(proof)
    end
  end
end
