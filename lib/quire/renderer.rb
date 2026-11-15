# frozen_string_literal: true

require "erb"
require "cgi"
require_relative "errors"
require_relative "theme"

module Quire
  # Renders ERB templates (layouts, partials) against a small view context.
  # Layout resolution order:
  #   1. <site>/themes/<name>/layouts/<layout>.html.erb
  #   2. <gem>/themes/<name>/layouts/<layout>.html.erb
  # If the theme has a base.html.erb and the layout is not "base", the result
  # is wrapped in base, with the inner HTML available as `content`.
  class Renderer
    def initialize(site, theme)
      @site = site
      @theme = theme
    end

    # Render a content page (post, page, index, ...) with its layout and wrap in base.
    def render_page(layout:, page:, content: nil, locals: {})
      inner = render_template(layout, page: page, content: content, locals: locals)

      base_path = find_layout("base")
      return inner if layout == "base" || base_path.nil?

      render_template("base", page: page, content: inner, locals: locals)
    end

    # Render a partial (_name.html.erb) and return the HTML string.
    def partial(name, page:, locals: {})
      path = @theme.partial_path(name)
      render_file(path, page: page, content: nil, locals: locals)
    end

    private

    def render_template(layout, page:, content:, locals:)
      path = @theme.layout_path(layout)
      render_file(path, page: page, content: content, locals: locals)
    end

    def find_layout(layout)
      @theme.layout_path(layout)
    rescue Error
      nil
    end

    def render_file(path, page:, content:, locals:)
      template = File.read(path, encoding: "bom|utf-8")
      context = ViewContext.new(self, @site, page, content, locals)
      ERB.new(template, trim_mode: "-").result(context.erb_binding)
    rescue Error
      raise
    rescue ScriptError, StandardError => e
      raise Error.new("failed to render #{path}: #{e.message}", file: path)
    end

    # Binding exposed to templates. Templates should call h() for any text
    # from content or config.
    class ViewContext
      def initialize(renderer, site, page, content, locals)
        @renderer = renderer
        @site = site
        @page = page
        @content = content

        locals.each do |key, value|
          define_singleton_method(key) { value }
        end
      end

      attr_reader :site, :page, :content

      def config = @site.config

      def h(text)
        CGI.escapeHTML(text.to_s)
      end

      def url(path)
        path ||= "/"
        if path.start_with?("http")
          path
        else
          "#{@site.config.base_url}#{path.start_with?('/') ? path : "/#{path}"}"
        end
      end

      def absolute_url(path)
        @site.config.absolute_url(path)
      end

      def asset_url(path)
        url("/assets/#{path}")
      end

      def tag_url(tag)
        "#{@site.config.base_url}/tags/#{Slug.slugify(tag)}/"
      end

      def tags_url
        "#{@site.config.base_url}/tags/"
      end

      def post_url(post)
        "#{@site.config.base_url}#{post.url}"
      end

      def page_url(doc)
        "#{@site.config.base_url}#{doc.url}"
      end

      def feed_url
        "#{@site.config.base_url}/feed.xml"
      end

      def partial(name, locals = {})
        @renderer.partial(name, page: @page, locals: locals)
      end

      def format_date(date)
        return "" if date.nil?

        "#{date.strftime('%B')} #{date.day}, #{date.year}"
      end

      def erb_binding
        binding
      end
    end
  end
end
