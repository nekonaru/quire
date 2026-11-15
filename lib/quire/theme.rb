# frozen_string_literal: true

require "yaml"
require_relative "errors"

module Quire
  # Resolves a theme by name. Layouts and assets are looked up in this order:
  #   1. <site>/themes/<name>/   (site can override single files)
  #   2. <gem>/themes/<name>/    (built-in)
  class Theme
    GEM_THEMES_DIR = File.expand_path("../../themes", __dir__)

    attr_reader :name, :dir, :site_dir

    def self.load(name, site_root)
      new(name, site_root)
    end

    def initialize(name, site_root)
      @name = name
      @site_dir = File.join(site_root, "themes", name)
      @dir = resolve_dir
      load_manifest
    end

    def manifest
      @manifest ||= {}
    end

    def layout_path(layout)
      find_file("layouts", "#{layout}.html.erb") ||
        raise(Error, "layout '#{layout}' not found in theme '#{name}' (looked in #{search_paths('layouts').join(', ')})")
    end

    # All candidate paths for a partial file, site first.
    def partial_path(partial)
      find_file("layouts", "_#{partial}.html.erb") ||
        raise(Error, "partial '_#{partial}' not found in theme '#{name}' (looked in #{search_paths('layouts').join(', ')})")
    end

    # Existing asset roots: site theme assets first, then built-in assets.
    def asset_dirs
      [File.join(@site_dir, "assets"), File.join(GEM_THEMES_DIR, @name, "assets")].uniq.select { |d| Dir.exist?(d) }
    end

    def layout_names
      search_paths("layouts").flat_map { |dir| Dir[File.join(dir, "*.html.erb")].map { |f| File.basename(f, ".html.erb") } }.uniq
    end

    private

    def resolve_dir
      return @site_dir if Dir.exist?(@site_dir)

      builtin = File.join(GEM_THEMES_DIR, @name)
      return builtin if Dir.exist?(builtin)

      raise Error, "unknown theme '#{@name}' (no themes/#{@name}/ in the site and none built in)"
    end

    def find_file(subdir, filename)
      search_paths(subdir).each do |base|
        candidate = File.join(base, filename)
        return candidate if File.exist?(candidate)
      end
      nil
    end

    def search_paths(subdir)
      paths = []
      paths << File.join(@site_dir, subdir) if Dir.exist?(File.join(@site_dir, subdir))
      builtin = File.join(GEM_THEMES_DIR, @name, subdir)
      paths << builtin if Dir.exist?(builtin)
      paths
    end

    def load_manifest
      @manifest = {}
      manifest_path = [@site_dir, @dir].map { |d| File.join(d, "theme.yml") }.find { |p| File.exist?(p) }
      @manifest = YAML.safe_load(File.read(manifest_path, encoding: "bom|utf-8"), permitted_classes: [Symbol]) || {} if manifest_path
      @manifest = @manifest.transform_keys(&:to_s)
    rescue Psych::SyntaxError => e
      raise Error.new("invalid YAML in theme.yml: #{e.message.strip}", file: manifest_path)
    end
  end
end
