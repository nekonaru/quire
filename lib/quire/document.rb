# frozen_string_literal: true

require "date"
require_relative "errors"
require_relative "front_matter"
require_relative "markdown"
require_relative "slug"

module Quire
  # A single piece of content: a post or a page. Wraps a Markdown file with
  # YAML front matter and exposes typed attributes with safe defaults.
  class Document
    DATE_PREFIX = /\A(\d{4}-\d{2}-\d{2})-(.+)\z/

    attr_reader :path, :kind, :attributes, :body, :front_matter_line

    def initialize(path, kind:)
      @path = path
      @kind = kind # :post or :page
      text = File.read(path, encoding: "bom|utf-8")
      @attributes, @body, @front_matter_line = FrontMatter.parse(text, file: path)
    end

    def title
      @title ||= (attributes["title"] || File.basename(path, ".md").sub(DATE_PREFIX, '\2').tr("-_", " ")).to_s
    end

    def slug
      @slug ||= Slug.slugify(attributes["slug"] || slug_source)
    end

    def date
      @date ||= normalize_date(attributes["date"]) || date_from_filename
    end

    def tags
      @tags ||= Array(attributes["tags"]).map(&:to_s)
    end

    def draft?
      truthy?(attributes["draft"])
    end

    def future?(today = Date.today)
      !date.nil? && date > today
    end

    def layout
      value = attributes["layout"].to_s.strip
      return default_layout if value.empty?

      unless value.match?(/\A[a-z0-9_-]+\z/)
        raise Error.new("layout must be a simple layout name (lowercase letters, numbers, - and _), got #{value.inspect}", file: path)
      end

      value
    end

    def description
      attributes["description"].to_s
    end

    def url
      kind == :post ? "/posts/#{slug}/" : "/#{slug}/"
    end

    def body_html(allow_html: false)
      @body_html ||= Markdown.render(body, file: path, allow_html: allow_html)
    end

    # Plain-text excerpt for feeds and meta tags: first block of body text.
    def excerpt(length: 160)
      text = body
             .gsub(/```.*?```/m, "")
             .gsub(/`[^`]*`/, "")
             .gsub(/!\[[^\]]*\]\([^)]*\)/, "")
             .gsub(/\[([^\]]*)\]\([^)]*\)/, '\1')
             .gsub(/[#>*_\-|]/, "")
             .gsub(/\s+/, " ")
             .strip
      text.length > length ? "#{text[0...length].rpartition(' ').first}..." : text
    end

    def file_name
      File.basename(path)
    end

    private

    def slug_source
      base = File.basename(path, ".md")
      match = base.match(DATE_PREFIX)
      match ? match[2] : base
    end

    def date_from_filename
      match = File.basename(path, ".md").match(DATE_PREFIX)
      return nil unless match

      Date.parse(match[1])
    rescue ArgumentError
      nil
    end

    def default_layout
      kind == :post ? "post" : "page"
    end

    def normalize_date(value)
      case value
      when nil then nil
      when Date then value
      when Time then Date.new(value.year, value.month, value.day)
      else
        Date.parse(value.to_s)
      end
    rescue ArgumentError, TypeError
      raise Error.new("invalid date #{value.inspect} (expected YYYY-MM-DD)", file: path, line: front_matter_line || 2)
    end

    def truthy?(value)
      return true if value == true || value.to_s.downcase == "true"

      false
    end
  end
end
