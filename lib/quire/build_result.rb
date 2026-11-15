# frozen_string_literal: true

module Quire
  # A single piece of content: a virtual page for generated pages (index,
  # tags, 404). Mirrors the Document interface the templates use.
  PageData = Struct.new(:title, :description, :url, :layout, keyword_init: true) do
    def date = nil
    def tags = []
    def excerpt = description.to_s
  end

  # What a build produced, returned by Builder#build.
  BuildResult = Struct.new(:output_dir, :posts, :pages, :tags, :files_written, :cached, :warnings,
                           keyword_init: true) do
    def summary
      return "No input changes since the last build; nothing to do." if cached

      "Built #{posts} posts, #{pages} pages, #{tags} tags into #{output_dir}"
    end
  end
end
