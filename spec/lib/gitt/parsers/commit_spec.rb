# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Parsers::Commit do
  using Refinements::Structs

  subject(:parser) { described_class.new }

  let :content_without_body do
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

  let :commit_without_body do
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
      lines: [],
      raw: "",
      sha: "180dec7d8ae8cbe3565a727c63c2111e49e0b737",
      signature: "None",
      subject: "Added documentation",
      trailers: []
    ]
  end

  describe ".call" do
    it "answers parsed commit" do
      expect(described_class.call(content_without_body)).to eq(commit_without_body)
    end
  end

  describe "#call" do
    it "answers commit without body" do
      expect(parser.call(content_without_body)).to eq(commit_without_body)
    end

    it "answers commit body lines and paragraphs with single body line" do
      expect(parser.call("<body>Test.\n</body>")).to have_attributes(
        body: "Test.",
        body_lines: ["Test."],
        body_paragraphs: ["Test."]
      )
    end

    it "answers commit body lines and paragraphs with multiple body lines" do
      expect(parser.call("<body>One.\nTwo.\nThree.\n</body>")).to have_attributes(
        body: "One.\nTwo.\nThree.",
        body_lines: ["One.", "Two.", "Three."],
        body_paragraphs: ["One.\nTwo.\nThree."]
      )
    end

    it "answers commit body lines and paragraphs with embedded comments" do
      expect(parser.call("<body>One.\n# Test.\nTwo.\n\nThree.\n</body>")).to have_attributes(
        body: "One.\n# Test.\nTwo.\n\nThree.",
        body_lines: ["One.", "# Test.", "Two.", "", "Three."],
        body_paragraphs: ["One.\n# Test.\nTwo.", "Three."]
      )
    end

    it "answers commit body lines and paragraphs with paragraphs" do
      expect(parser.call("<body>One.\n\nTwo.\n\nThree.\n</body>")).to have_attributes(
        body: "One.\n\nTwo.\n\nThree.",
        body_lines: ["One.", "", "Two.", "", "Three."],
        body_paragraphs: ["One.", "Two.", "Three."]
      )
    end

    it "answers commit body lines and paragraphs with multiple paragraphs" do
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

    it "answers empty commit body lines and paragraphs with commented paragraphs only" do
      body = "# One.\n\n# Two.\n\n# Three."

      expect(parser.call("<body>#{body}</body>")).to have_attributes(
        body:,
        body_lines: ["# One.", "", "# Two.", "", "# Three."],
        body_paragraphs: ["# One.", "# Two.", "# Three."]
      )
    end

    it "answers commit body lines and paragraphs with mixed paragraphs of comments and text" do
      body = "One.\n\n# Two A.\n# Two B.\n\nThree."

      expect(parser.call("<body>#{body}</body>")).to have_attributes(
        body:,
        body_lines: ["One.", "", "# Two A.", "# Two B.", "", "Three."],
        body_paragraphs: ["One.", "# Two A.\n# Two B.", "Three."]
      )
    end

    it "answers commit body lines, paragraphs, and trailers" do
      content = <<~CONTENT
        <body>One.\n\nOne: 1\nTwo: 2\n</body>
        <trailers>One: 1\nTwo: 2\n</trailers>
      CONTENT

      expect(parser.call(content)).to have_attributes(
        body: "One.",
        body_lines: ["One."],
        body_paragraphs: ["One."],
        trailers: [
          Gitt::Models::Trailer[key: "One", delimiter: ":", space: " ", value: "1"],
          Gitt::Models::Trailer[key: "Two", delimiter: ":", space: " ", value: "2"]
        ]
      )
    end

    it "answers commit body lines and paragraphs with trailers and suffixed comments" do
      content = <<~CONTENT
        <body>One.\n\nOne: 1\n\n# One.\n\n# Two.\n</body>
        <trailers>One: 1\n</trailers>
      CONTENT

      expect(parser.call(content)).to have_attributes(
        body: "One.\n\n# One.\n\n# Two.",
        body_lines: ["One.", "", "# One.", "", "# Two."],
        body_paragraphs: ["One.", "# One.", "# Two."],
        trailers: [
          Gitt::Models::Trailer[key: "One", delimiter: ":", space: " ", value: "1"]
        ]
      )
    end

    it "answers commit trailers with special characters" do
      content = <<~CONTENT
        <body>One.\n\nA: #!+\nIssue: [x-1]\n</body>
        <trailers>A: #!+\nIssue: [x-1]\n</trailers>
      CONTENT

      expect(parser.call(content)).to have_attributes(
        body: "One.",
        body_lines: ["One."],
        body_paragraphs: ["One."],
        trailers: [
          Gitt::Models::Trailer[key: "A", delimiter: ":", space: " ", value: "#!+"],
          Gitt::Models::Trailer[key: "Issue", delimiter: ":", space: " ", value: "[x-1]"]
        ]
      )
    end
  end
end
