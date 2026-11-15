# frozen_string_literal: true

require "yaml"
require_relative "errors"

module Quire
  # Loads and normalizes quire.yml for a site.
  #
  #   title: My Site           # required-ish, falls back to site name
  #   description: What this is
  #   author: Jane Doe
  #   base_url: https://example.com   # no trailing slash; may be empty
  #   theme: blog              # blog (default) or portfolio, or a custom one
  #   posts_per_page: 10
  #   menu:                    # list of { title, url } for the nav bar
  #     - { title: About, url: /about/ }
  #   markdown:
  #     allow_html: false      # raw HTML passthrough, default false
  class Config
    FILE_NAME = "quire.yml"

    DEFAULTS = {
      "title" => "Quire Site",
      "description" => "",
      "author" => "",
      "base_url" => "",
      "theme" => "blog",
      "posts_per_page" => 10,
      "menu" => [],
      "markdown" => { "allow_html" => false },
      "email" => nil,
      "social" => {}
    }.freeze

    attr_reader :root, :data

    def initialize(root)
      @root = File.expand_path(root)
      @data = load_file
      normalize!
    end

    def [](key)
      @data[key]
    end

    def title = @data["title"]
    def description = @data["description"]
    def author = @data["author"]
    def theme = @data["theme"]
    def menu = @data["menu"]
    def email = @data["email"]
    def social = @data["social"]
    def posts_per_page = @data["posts_per_page"]
    def allow_html? = !!@data.dig("markdown", "allow_html")

    # Base URL with no trailing slash, or "" when not configured.
    def base_url
      @data["base_url"].to_s.sub(%r{/+\z}, "")
    end

    # Absolute URL for a site-relative path ("/posts/x/" -> "https://x/y/posts/x/").
    def absolute_url(path)
      path = "/#{path}" unless path.start_with?("/", "http")
      return path if path.start_with?("http")

      "#{base_url}#{path}"
    end

    private

    def load_file
      path = File.join(@root, FILE_NAME)
      unless File.exist?(path)
        raise Error.new("missing #{FILE_NAME} in #{@root} (run `quire new site NAME` or create one)",
                        file: FILE_NAME)
      end

      merge_with_defaults(read_yaml(path))
    rescue Psych::SyntaxError => e
      raise Error.new("invalid YAML in #{FILE_NAME}: #{e.message.strip}", file: FILE_NAME, line: e.line)
    end

    def read_yaml(path)
      raw = YAML.safe_load(File.read(path, encoding: "bom|utf-8"), permitted_classes: [Symbol], aliases: false)
      return {} if raw.nil?

      raise Error.new("#{FILE_NAME} must be a YAML mapping (key: value), got #{raw.class}", file: FILE_NAME) unless raw.is_a?(Hash)

      raw
    end

    def merge_with_defaults(data)
      DEFAULTS.merge(data.transform_keys(&:to_s)) do |_key, default, given|
        default.is_a?(Hash) && given.is_a?(Hash) ? default.merge(given.transform_keys(&:to_s)) : given
      end
    end

    def normalize!
      @data["base_url"] = @data["base_url"].to_s.sub(%r{/+\z}, "")
      @data["posts_per_page"] = Integer(@data["posts_per_page"])
      @data["menu"] = normalize_menu(@data["menu"])
      unless @data["theme"].to_s.match?(/\A[a-z0-9_-]+\z/)
        raise Error.new("theme must be a simple theme name (lowercase letters, numbers, - and _), got #{@data['theme'].inspect}",
                        file: FILE_NAME)
      end
    rescue ArgumentError, TypeError
      raise Error.new("posts_per_page must be an integer in #{FILE_NAME}", file: FILE_NAME)
    end

    def normalize_menu(menu)
      raise Error.new("menu must be a list of { title, url } entries in #{FILE_NAME}", file: FILE_NAME) unless menu.is_a?(Array)

      menu.map do |entry|
        unless entry.is_a?(Hash) && entry["title"] && entry["url"]
          raise Error.new("each menu entry needs a title and a url in #{FILE_NAME}", file: FILE_NAME)
        end

        { "title" => entry["title"].to_s, "url" => entry["url"].to_s }
      end
    end
  end
end
