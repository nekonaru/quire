# frozen_string_literal: true

require "cgi"

module Quire
  # Builds an Atom feed for the most recent posts.
  class Feed
    LIMIT = 20

    def initialize(site)
      @site = site
    end

    def to_xml(posts)
      config = @site.config
      updated = (posts.map(&:date).compact.max || Date.today).to_time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      entries = posts.first(LIMIT).map { |post| entry(post) }.join("\n")

      <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <title>#{esc(config.title)}</title>
          <subtitle>#{esc(config.description)}</subtitle>
          <link href="#{esc(config.base_url)}/feed.xml" rel="self"/>
          <link href="#{esc(config.base_url)}/"/>
          <id>#{esc(config.base_url)}/</id>
          <updated>#{updated}</updated>
          <author><name>#{esc(config.author)}</name></author>
        #{entries}
        </feed>
      XML
    end

    private

    def entry(post)
      config = @site.config
      url = "#{config.base_url}#{post.url}"
      updated = (post.date || Date.today).to_time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")

      <<~XML
        <entry>
          <title>#{esc(post.title)}</title>
          <link href="#{esc(url)}"/>
          <id>#{esc(url)}</id>
          <updated>#{updated}</updated>
          <summary>#{esc(post.description.empty? ? post.excerpt : post.description)}</summary>
        </entry>
      XML
    end

    def esc(text)
      CGI.escapeHTML(text.to_s)
    end
  end
end
