# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require_relative "config"
require_relative "theme"

module Quire
  # Computes a content hash of everything that feeds a build (config, content,
  # data, static files, theme files) and remembers the last hash in
  # .quire-cache.json, so an unchanged site can skip the build entirely.
  class BuildCache
    CACHE_FILE = ".quire-cache.json"

    def initialize(root)
      @root = File.expand_path(root)
    end

    def fresh?(theme)
      cached = read_cache
      !!(cached && cached["manifest"] == manifest(theme))
    end

    def write(theme)
      path = File.join(@root, CACHE_FILE)
      File.write(path, JSON.pretty_generate({ "manifest" => manifest(theme), "built_at" => Time.now.utc.iso8601 }))
    end

    def delete
      FileUtils.rm_f(File.join(@root, CACHE_FILE))
    end

    def manifest(theme)
      files = site_input_files + theme_input_files(theme)

      digest = Digest::MD5.new
      files.sort.uniq.each do |file|
        digest << File.expand_path(file) << File.binread(file) if File.file?(file)
      end
      digest.hexdigest
    end

    private

    def site_input_files
      files = [File.join(@root, Config::FILE_NAME)]
      files += Dir[File.join(@root, "content", "**", "*.md")]
      files += Dir[File.join(@root, "data", "*.{yml,yaml}")]
      files += Dir[File.join(@root, "static", "**", "*")]
      files.reject { |f| File.directory?(f) }
    end

    def theme_input_files(theme)
      files = theme.asset_dirs.flat_map { |d| Dir[File.join(d, "**", "*")] }
      files += Dir[File.join(Theme::GEM_THEMES_DIR, theme.name, "layouts", "*.html.erb")]
      files += Dir[File.join(Theme::GEM_THEMES_DIR, theme.name, "theme.yml")]
      site_theme = File.join(@root, "themes", theme.name)
      files += Dir[File.join(site_theme, "**", "*")] if Dir.exist?(site_theme)
      files.reject { |f| File.directory?(f) }
    end

    def read_cache
      path = File.join(@root, CACHE_FILE)
      return nil unless File.exist?(path)

      JSON.parse(File.read(path))
    rescue JSON::ParserError
      nil
    end
  end
end
