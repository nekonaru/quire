# frozen_string_literal: true

require "yaml"
require_relative "config"
require_relative "document"
require_relative "errors"

module Quire
  # The site model: posts, pages, tags and data files, loaded from a site
  # root directory. Nothing here writes to disk; the builder decides where
  # output goes.
  class Site
    attr_reader :root, :config

    def initialize(root)
      @root = File.expand_path(root)
      @config = Config.new(@root)
    end

    def posts(drafts: false, future: false, today: Date.today)
      all_posts = @posts_all ||= load_documents("content/posts", kind: :post)
      all_posts
        .select { |post| post_visible?(post, drafts: drafts, future: future, today: today) }
        .sort_by { |post| post.date || Date.new(1970, 1, 1) }
        .reverse
    end

    def pages(drafts: false)
      @pages_all ||= load_documents("content/pages", kind: :page)
      @pages_all.select { |page| drafts || !page.draft? }
    end

    def tags(drafts: false, future: false)
      index = Hash.new { |hash, key| hash[key] = [] }
      posts(drafts: drafts, future: future).each do |post|
        post.tags.each { |tag| index[tag] << post }
      end
      index
    end

    # data/*.yml becomes site.data["name"] = loaded YAML
    def data
      @data ||= load_data_files
    end

    private

    def post_visible?(post, drafts:, future:, today:)
      return false if !drafts && post.draft?
      return false if !future && post.future?(today)

      true
    end

    def load_documents(relative_dir, kind:)
      dir = File.join(@root, relative_dir)
      return [] unless Dir.exist?(dir)

      Dir[File.join(dir, "**", "*.md")].map do |path|
        Document.new(path, kind: kind)
      rescue Error
        raise
      rescue StandardError => e
        raise Error.new(e.message, file: path)
      end
    end

    def load_data_files
      dir = File.join(@root, "data")
      return {} unless Dir.exist?(dir)

      Dir[File.join(dir, "*.{yml,yaml}")].to_h do |path|
        key = File.basename(path, File.extname(path))
        begin
          [key, YAML.safe_load(File.read(path, encoding: "bom|utf-8"), permitted_classes: [Date, Time, Symbol], aliases: false)]
        rescue Psych::SyntaxError => e
          raise Error.new("invalid YAML in data file: #{e.message.strip}", file: path, line: e.line)
        end
      end
    end
  end
end
