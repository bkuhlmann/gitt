# frozen_string_literal: true

require "dry/monads"

module Gitt
  module Commands
    # A Git log command wrapper.
    class Log
      include Dry::Monads[:result]

      KEY_MAP = {
        author_email: "%ae",
        author_name: "%an",
        authored_at: "%at",
        authored_relative_at: "%ar",
        body: "%b",
        committed_at: "%ct",
        committed_relative_at: "%cr",
        committer_email: "%ce",
        committer_name: "%cn",
        encoding: "%e",
        notes: "%N",
        raw: "%B",
        sha: "%H",
        signature: "%G?",
        fingerprint: "%GK",
        fingerprint_key: "%GF",
        subject: "%s",
        trailers: "%(trailers)"
      }.freeze

      def initialize shell: SHELL, key_map: KEY_MAP, parser: Parsers::Commit.new
        @shell = shell
        @key_map = key_map
        @parser = parser
      end

      def call(*, **) = shell.call("log", *, **)

      def index(*arguments, **)
        arguments.prepend("--shortstat", pretty_format)
                 .then { |pretty_format| call(*pretty_format, **) }
                 .fmap { |content| String(content).scrub("?") }
                 .fmap { |entries| build_records entries }
      end

      def uncommitted path
        return Failure %(Invalid commit message path: "#{path}".) unless path.exist?

        shell.call("mktree")
             .bind { |raw_sha| shell.call "commit-tree", "-F", path.to_s, raw_sha.chomp }
             .bind { |sha| index "-1", sha.chomp }
             .fmap(&:first)
      end

      private

      attr_reader :shell, :key_map, :parser

      def pretty_format
        key_map.reduce(+"") { |format, (key, value)| format << "<#{key}>#{value}</#{key}>%n" }
               .then { |format| %(--pretty=format:"#{format}") }
      end

      def build_records entries
        wrap_statistics entries
        add_empty_statistics entries
        entries.split("<break/>").map { |entry| parser.call entry }
      end

      # :reek:UtilityFunction
      def wrap_statistics entries
        entries.gsub!(/\n"\n\s\d+\sfile.+\d+\s(insertion|deletion).+\n/) do |match|
          match.delete_prefix!("\n\"\n").strip!
          "\n<statistics>#{match}</statistics>\n<break/>"
        end
      end

      # :reek:UtilityFunction
      def add_empty_statistics entries
        entries.gsub! %(</trailers>\n"\n"<author_email>),
                      "</trailers>\n<statistics></statistics><break/>\n<author_email>"
      end
    end
  end
end
