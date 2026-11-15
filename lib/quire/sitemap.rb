# frozen_string_literal: true

require "cgi"

module Quire
  # Builds sitemap.xml from the URLs generated for the site.
  class Sitemap
    def initialize(base_url)
      @base_url = base_url.to_s.sub(%r{/+\z}, "")
    end

    # urls: array of path strings like "/posts/hello/"
    def to_xml(urls)
      entries = urls.uniq.map { |path| "  <url><loc>#{CGI.escapeHTML(@base_url + path)}</loc></url>" }.join("\n")

      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
        #{entries}
        </urlset>
      XML
    end
  end
end
