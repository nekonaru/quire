# frozen_string_literal: true

require_relative "quire/version"
require_relative "quire/errors"
require_relative "quire/slug"
require_relative "quire/front_matter"
require_relative "quire/markdown"
require_relative "quire/config"
require_relative "quire/document"
require_relative "quire/site"
require_relative "quire/theme"
require_relative "quire/renderer"
require_relative "quire/paginator"
require_relative "quire/feed"
require_relative "quire/sitemap"
require_relative "quire/build_cache"
require_relative "quire/build_result"
require_relative "quire/feed_sitemap_writer"
require_relative "quire/generated_pages"
require_relative "quire/config_poller"
require_relative "quire/builder"
require_relative "quire/http_helpers"
require_relative "quire/server"
require_relative "quire/cli"

# Quire is a static site generator: Markdown files with YAML front matter in,
# a static HTML/CSS site out.
module Quire
end
