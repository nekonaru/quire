# frozen_string_literal: true

require "fileutils"
require_relative "build_cache"
require_relative "build_result"
require_relative "feed_sitemap_writer"
require_relative "generated_pages"
require_relative "renderer"
require_relative "site"
require_relative "theme"

module Quire
  # Builds a site into its output directory (default: <root>/public).
  class Builder
    CACHE_FILE = BuildCache::CACHE_FILE

    def initialize(root, output_dir: nil, drafts: false, future: false, force: false)
      @root = File.expand_path(root)
      @output_dir = output_dir ? File.expand_path(output_dir) : File.join(@root, "public")
      @drafts = drafts
      @future = future
      @force = force
      @warnings = []
      @cache = BuildCache.new(@root)
    end

    def build
      site = Site.new(@root)
      theme = Theme.load(site.config.theme, @root)
      return cached_result if cached_build?(theme)

      FileUtils.rm_rf(@output_dir)
      FileUtils.mkdir_p(@output_dir)

      renderer = Renderer.new(site, theme)
      posts, pages, tags = load_content(site)

      count = write_all(renderer, site, posts, pages, tags)

      copy_assets(theme)
      copy_static

      @cache.write(theme)
      BuildResult.new(output_dir: @output_dir, posts: posts.size, pages: pages.size, tags: tags.size,
                      files_written: count, cached: false, warnings: @warnings)
    end

    private

    def cached_build?(theme)
      # Draft/future flags change the output set, so never serve from the cache.
      !@force && !@drafts && !@future && @cache.fresh?(theme) && File.directory?(@output_dir)
    end

    def cached_result
      BuildResult.new(output_dir: @output_dir, posts: 0, pages: 0, tags: 0, files_written: 0,
                      cached: true, warnings: [])
    end

    def load_content(site)
      [site.posts(drafts: @drafts, future: @future),
       site.pages(drafts: @drafts),
       site.tags(drafts: @drafts, future: @future)]
    end

    def write_all(renderer, site, posts, pages, tags)
      allow_html = site.config.allow_html?
      count = write_documents(posts, renderer, allow_html)
      count += write_documents(pages, renderer, allow_html)

      generated = GeneratedPages.new(@output_dir)
      count += generated.build_home(renderer, site, posts)
      count += generated.build_tags(renderer, tags)
      count += build_not_found(renderer)
      count + build_feed_sitemap_robots(site, posts, pages, tags)
    end

    def write_documents(documents, renderer, allow_html)
      count = 0
      documents.each do |document|
        html = renderer.render_page(layout: document.layout, page: document,
                                    content: document.body_html(allow_html: allow_html))
        write_page(document.url, html)
        count += 1
      end
      count
    end

    # Writes <dir>/index.html under output_dir for a URL like "/posts/x/".
    def write_page(url_path, html)
      write_file(File.join(@output_dir, url_path, "index.html"), html)
    end

    def write_file(path, content)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
      1
    end

    def build_not_found(renderer)
      write_file(File.join(@output_dir, "404.html"),
                 renderer.render_page(
                   layout: "404",
                   page: PageData.new(title: "Page not found",
                                      description: "The page you were looking for does not exist.",
                                      url: "/404.html", layout: "404"),
                   content: nil
                 ))
    end

    def build_feed_sitemap_robots(site, posts, pages, tags)
      warnings = FeedSitemapWriter.new(@output_dir).call(site, posts, pages, tags)
      @warnings.concat(warnings)
      3
    end

    def copy_assets(theme)
      dest = File.join(@output_dir, "assets")
      # Built-in first, site theme overrides on top.
      theme.asset_dirs.reverse_each do |dir|
        FileUtils.mkdir_p(dest)
        FileUtils.cp_r(Dir[File.join(dir, "*")].map(&:to_s), dest, preserve: false)
      end
    end

    def copy_static
      static_dir = File.join(@root, "static")
      return unless Dir.exist?(static_dir)

      FileUtils.cp_r(Dir[File.join(static_dir, "*")].map(&:to_s), @output_dir, preserve: false)
    end
  end
end
