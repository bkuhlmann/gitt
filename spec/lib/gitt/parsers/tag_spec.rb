# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Parsers::Tag do
  subject(:parser) { described_class.new }

  describe "#call" do
    it "answers record" do
      content = <<~CONTENT
        <author_email><test@example.com></author_email>
        <author_name>Test User</author_name>
        <authored_at>1668984438 -0700</authored_at>
        <authored_relative_at>0 seconds ago</authored_relative_at>
        <body>This is a test.</body>
        <committed_at>1668984438 -0700</committed_at>
        <committed_relative_at>0 seconds ago</committed_relative_at>
        <committer_email><test@example.com></committer_email>
        <committer_name>Test User</committer_name>
        <sha>180dec7d8ae8cbe3565a727c63c2111e49e0b737</sha>
        <signature></signature>
        <subject>Version 0.0.0</subject>
        <version>refs/tags/0.0.0</version>
      CONTENT

      expect(parser.call(content)).to have_attributes(
        author_email: "test@example.com",
        author_name: "Test User",
        authored_at: "1668984438",
        authored_relative_at: "0 seconds ago",
        body: "This is a test.",
        committed_at: "1668984438",
        committed_relative_at: "0 seconds ago",
        committer_email: "test@example.com",
        committer_name: "Test User",
        sha: "180dec7d8ae8cbe3565a727c63c2111e49e0b737",
        signature: "",
        subject: "Version 0.0.0",
        version: "0.0.0"
      )
    end

    it "strips author email of less than and greater than characters" do
      expect(parser.call("<author_email><test@example.com></author_email>")).to have_attributes(
        author_email: "test@example.com"
      )
    end

    it "strips authored at of time zone" do
      expect(parser.call("<authored_at>1668984438 -0700</authored_at>")).to have_attributes(
        authored_at: "1668984438"
      )
    end

    it "strips committed at of time zone" do
      expect(parser.call("<committed_at>1668984438 -0700</committed_at>")).to have_attributes(
        committed_at: "1668984438"
      )
    end

    it "strips committer email of less than and greater than characters" do
      expect(parser.call("<committer_email><a@b.com></committer_email>")).to have_attributes(
        committer_email: "a@b.com"
      )
    end

    it "answers strips version of tag reference path" do
      expect(parser.call("<version>refs/tags/0.0.0</version>")).to have_attributes(
        version: "0.0.0"
      )
    end
  end
end
