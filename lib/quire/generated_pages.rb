# frozen_string_literal: true

require "fileutils"
require_relative "build_result"
require_relative "paginator"
require_relative "slug"

module Quire
  # Writes the generated listing pages (home with pagination, tag index and
  # tag pages) into the output directory.
  class GeneratedPages
    def initialize(output_dir)
      @output_dir = output_dir
    end

    def build_home(renderer, site, posts)
      per_page = site.config.posts_per_page
      total_pages = Paginator.new(posts.size, per_page).total_pages
      count = 0

      (1..total_pages).each do |number|
        pager = Paginator.new(posts.size, per_page, number)
        url = Paginator.url_for(number)
        title = number == 1 ? site.config.title : "Page #{number} - #{site.config.title}"
        virtual = PageData.new(title: title, description: site.config.description, url: url, layout: "index")
        html = renderer.render_page(layout: "index", page: virtual, content: nil,
                                    locals: { posts: pager.slice(posts), pagination: pager })
        path = url == "/" ? "index.html" : File.join(url, "index.html")
        count += write_page(path, html)
      end
      count
    end

    def build_tags(renderer, tags)
      count = write_tag_index(renderer, tags)

      tags.each do |tag, tagged_posts|
        slug = Slug.slugify(tag)
        html = renderer.render_page(
          layout: "tag",
          page: PageData.new(title: "Tag: #{tag}", description: "Posts tagged #{tag}.",
                             url: "/tags/#{slug}/", layout: "tag"),
          content: nil,
          locals: { posts: tagged_posts, tag: tag }
        )
        count += write_page("tags/#{slug}/index.html", html)
      end
      count
    end

    private

    def write_tag_index(renderer, tags)
      html = renderer.render_page(
        layout: "tags",
        page: PageData.new(title: "Tags", description: "Browse all tags.", url: "/tags/", layout: "tags"),
        content: nil,
        locals: { tags: tags, tag_list: tags.keys.sort }
      )
      write_page("tags/index.html", html)
    end

    def write_page(relative_path, html)
      path = File.join(@output_dir, relative_path)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, html)
      1
    end
  end
end
