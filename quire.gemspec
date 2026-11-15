# frozen_string_literal: true

require_relative "lib/quire/version"

Gem::Specification.new do |spec|
  spec.name = "quire"
  spec.version = Quire::VERSION
  spec.authors = ["Nicolas Dwi Dharma"]
  spec.email = ["nekonaru@users.noreply.github.com"]

  spec.summary = "Static site generator written in Ruby"
  spec.description = "Quire turns a folder of Markdown files with YAML front matter " \
                     "into a static site (HTML/CSS) ready to deploy to GitHub Pages, " \
                     "Netlify, or Cloudflare Pages. Ships with blog and portfolio themes."
  spec.homepage = "https://github.com/nekonaru/quire"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "#{spec.homepage}/tree/main",
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.start_with?(*%w[spec/ examples/ .github/]) || f == "Gemfile.lock"
    end
  end
  spec.bindir = "exe"
  spec.executables = ["quire"]
  spec.require_paths = ["lib"]

  spec.add_dependency "kramdown", "~> 2.4"
  spec.add_dependency "kramdown-parser-gfm", "~> 1.1"
  spec.add_dependency "listen", "~> 3.8"
  spec.add_dependency "rouge", "~> 4.2"
  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "webrick", "~> 1.8"
end
