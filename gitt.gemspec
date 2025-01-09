# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "gitt"
  spec.version = "4.1.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://alchemists.io/projects/gitt"
  spec.summary = "A monadic Object API for the Git CLI."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/gitt/issues",
    "changelog_uri" => "https://alchemists.io/projects/gitt/versions",
    "homepage_uri" => "https://alchemists.io/projects/gitt",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Gitt",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/gitt"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.4"
  spec.add_dependency "core", "~> 2.0"
  spec.add_dependency "dry-monads", "~> 1.6"
  spec.add_dependency "refinements", "~> 13.0"
  spec.add_dependency "zeitwerk", "~> 2.7"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
