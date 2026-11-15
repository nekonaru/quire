# frozen_string_literal: true

require "kramdown"
require "kramdown-parser-gfm"
require_relative "errors"

module Quire
  # Renders Markdown bodies to HTML using kramdown (GFM input) and rouge
  # for syntax highlighting.
  #
  # Raw HTML in the source is escaped by default so a Markdown file cannot
  # inject markup into the site. Set `allow_html: true` in quire.yml under
  # `markdown:` to pass raw HTML through.
  module Markdown
    FENCED_CODE = /^(`{3,}|~{3,})/

    module_function

    # Render a Markdown body to HTML.
    # file is used only for error reporting.
    def render(text, file: nil, allow_html: false)
      source = allow_html ? text : escape_html_outside_code(text)

      Kramdown::Document.new(
        source,
        input: "GFM",
        syntax_highlighter: "rouge",
        syntax_highlighter_opts: { css_class: "highlight" },
        footnote_nr: 1
      ).to_html
    rescue Kramdown::Error => e
      raise Error.new("Markdown error: #{e.message}", file: file)
    end

    # Escape &, < and > in everything outside fenced code blocks and inline
    # code spans. Code content keeps its characters so it survives kramdown's
    # own escaping untouched.
    def escape_html_outside_code(text)
      result = +""
      in_code_fence = false
      text.each_line do |line|
        if line.match?(FENCED_CODE)
          in_code_fence = !in_code_fence
          result << line
          next
        end
        result << (in_code_fence ? line : escape_inline(line))
      end
      result
    end

    def escape_inline(line)
      # Split on inline code spans (single backticks), escape the odd parts.
      parts = line.split(/(`[^`\n]*`)/)
      parts.each_with_index.map do |part, index|
        if index.odd?
          part
        else
          part.gsub(/&(?!(?:[a-zA-Z][a-zA-Z0-9]*|#\d+|#x[0-9a-fA-F]+);)/, "&amp;")
              .gsub("<", "&lt;")
              .gsub(">", "&gt;")
        end
      end.join
    end
  end
end
