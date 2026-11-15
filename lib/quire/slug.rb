# frozen_string_literal: true

module Quire
  # Turns a title into a URL-safe slug. ASCII only, lowercase, hyphenated.
  module Slug
    module_function

    def slugify(text)
      text.to_s
          .unicode_normalize(:nfkd)
          .gsub(/[^\x00-\x7F]/, "")
          .downcase
          .gsub(/[^a-z0-9]+/, "-")
          .gsub(/\A-+|-+\z/, "")
    end
  end
end
