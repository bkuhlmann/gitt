# frozen_string_literal: true

require "dry/monads"
require "tempfile"

module Gitt
  module Commands
    # A Git tag command wrapper.
    class Tag
      include Dry::Monads[:result]

      KEY_MAP = {
        author_email: "%(*authoremail)",
        author_name: "%(*authorname)",
        authored_at: "%(*authordate:raw)",
        authored_relative_at: "%(*authordate:relative)",
        committed_at: "%(*committerdate:raw)",
        committed_relative_at: "%(*committerdate:relative)",
        committer_email: "%(*committeremail)",
        committer_name: "%(*committername)",
        body: "%(body)",
        sha: "%(objectname)",
        subject: "%(subject)",
        version: "%(refname)"
      }.freeze

      def initialize shell: SHELL, key_map: KEY_MAP, parser: Parsers::Tag.new
        @shell = shell
        @key_map = key_map
        @parser = parser
      end

      def call(*arguments) = shell.call "tag", *arguments

      def create version, body = EMPTY_STRING, *flags
        return Failure "Unable to create Git tag without version." unless version
        return Failure "Tag exists: #{version}." if exist? version

        Tempfile.open "git_plus" do |file|
          file.write body
          write version, file.tap(&:rewind), *flags
        end
      end

      def exist?(version) = local?(version) || remote?(version)

      def index *arguments
        arguments.prepend(pretty_format, "--list")
                 .then { |flags| call(*flags) }
                 .fmap { |content| String(content).scrub("?").split %("\n") }
                 .fmap { |entries| build_records entries }
      end

      def last
        shell.call("describe", "--abbrev=0", "--tags", "--always")
             .fmap(&:strip)
             .or { |error| Failure error.delete_prefix("fatal: ").chomp }
      end

      def local?(version) = call("--list", version).value_or(EMPTY_STRING).match?(/\A#{version}\Z/)

      def push = shell.call "push", "--tags"

      def remote? version
        shell.call("ls-remote", "--tags", "origin", version)
             .value_or(EMPTY_STRING)
             .match?(%r(.+tags/#{version}\Z))
      end

      def show version
        call(pretty_format, "--list", version).fmap { |content| parser.call content }
      end

      def tagged? = !call.value_or(EMPTY_STRING).empty?

      private

      attr_reader :shell, :key_map, :parser

      def pretty_format
        key_map.reduce("") { |content, (key, value)| content + "<#{key}>#{value}</#{key}>%n" }
               .then { |format| %(--format="#{format}") }
      end

      def build_records(entries) = entries.map { |entry| parser.call entry }

      def write version, file, *flags
        arguments = ["--annotate", version, "--cleanup", "verbatim", *flags, "--file", file.path]
        call(*arguments).fmap { version }
                        .or { Failure "Unable to create tag: #{version}." }
      end
    end
  end
end
