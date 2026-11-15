# frozen_string_literal: true

require "fileutils"
require_relative "feed"
require_relative "paginator"
require_relative "sitemap"
require_relative "slug"

module Quire
  # Writes feed.xml, sitemap.xml and robots.txt into the output directory.
  class FeedSitemapWriter
    def initialize(output_dir)
      @output_dir = output_dir
    end

    # Returns a list of warnings (for example, when base_url is not set).
    def call(site, posts, pages, tags)
      base = site.config.base_url
      warnings = []
      warnings << "base_url is not set; feed.xml and sitemap.xml use relative URLs" if base.empty?

      write_feed(site, posts)
      write_sitemap(base, site, posts, pages, tags)
      write_robots(base)
      warnings
    end

    private

    def write_feed(site, posts)
      write_file("feed.xml", Feed.new(site).to_xml(posts))
    end

    def write_sitemap(base, site, posts, pages, tags)
      urls = ["/"]
      urls += Paginator.new(posts.size, site.config.posts_per_page).page_urls.drop(1)
      urls += posts.map(&:url)
      urls += pages.map(&:url)
      urls << "/tags/"
      urls += tags.keys.map { |tag| "/tags/#{Slug.slugify(tag)}/" }
      write_file("sitemap.xml", Sitemap.new(base).to_xml(urls))
    end

    def write_robots(base)
      robots = ["User-agent: *", "Allow: /"]
      robots << "Sitemap: #{base}/sitemap.xml" unless base.empty?
      write_file("robots.txt", "#{robots.join("\n")}\n")
    end

    def write_file(name, content)
      path = File.join(@output_dir, name)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
    end
  end
end
