# frozen_string_literal: true

module Quire
  # Turns a title into a URL-safe slug. ASCII only, lowercase, hyphenated.
  module Slug
    module_function

    def slugify(text)
      s = text.to_s
      s = s.encode(Encoding::UTF_8, invalid: :replace, replace: "") if s.encoding != Encoding::UTF_8
      s = s.scrub
      s.unicode_normalize(:nfkd)
       .gsub(/[^\x00-\x7F]/, "")
       .downcase
       .gsub(/[^a-z0-9]+/, "-")
       .gsub(/\A-+|-+\z/, "")
    end
  end
end
