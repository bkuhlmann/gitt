# frozen_string_literal: true

require "core"

module Gitt
  # Primary object/wrapper for processing all Git related commands.
  class Repository
    COMMANDS = {
      branch: Commands::Branch,
      config: Commands::Config,
      log: Commands::Log,
      tag: Commands::Tag
    }.freeze

    def initialize shell: SHELL, commands: COMMANDS
      @shell = shell
      @commands = commands.transform_values { |command| command.new shell: }
    end

    def branch(...) = commands.fetch(__method__).call(...)

    def branch_default(...) = commands.fetch(:branch).default(...)

    def branch_name = commands.fetch(:branch).name

    def call(...) = shell.call(...)

    def commits(...) = commands.fetch(:log).index(...)

    def config(...) = commands.fetch(__method__).call(...)

    def exist? = shell.call("rev-parse", "--git-dir").value_or(Core::EMPTY_STRING).chomp == ".git"

    def get(...) = commands.fetch(:config).get(...)

    def inspect
      "#<#{self.class}:#{object_id} @shell=#{shell.inspect} " \
      "@commands=#{commands.values.map(&:class).inspect}>"
    end

    def log(...) = commands.fetch(__method__).call(...)

    def origin? = commands.fetch(:config).origin?

    def set(...) = commands.fetch(:config).set(...)

    def tag(...) = commands.fetch(__method__).call(...)

    def tags(...) = commands.fetch(:tag).index(...)

    def tag?(...) = commands.fetch(:tag).exist?(...)

    def tag_create(...) = commands.fetch(:tag).create(...)

    def tag_last = commands.fetch(:tag).last

    def tag_local?(...) = commands.fetch(:tag).local?(...)

    def tag_remote?(...) = commands.fetch(:tag).remote?(...)

    def tag_show(...) = commands.fetch(:tag).show(...)

    def tagged? = commands.fetch(:tag).tagged?

    def tags_push = commands.fetch(:tag).push

    def uncommitted(...) = commands.fetch(:log).uncommitted(...)

    private

    attr_reader :shell, :commands
  end
end
