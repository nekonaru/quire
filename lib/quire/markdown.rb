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

    # Escape &, < and > in everything outside fenced code blocks, inline
    # code spans and indented code blocks. Code content keeps its characters
    # so it survives kramdown's own escaping untouched.
    def escape_html_outside_code(text)
      result = +""
      in_code_fence = false
      previous_blank = true
      text.each_line do |line|
        if line.match?(FENCED_CODE)
          in_code_fence = !in_code_fence
          result << line
          previous_blank = false
          next
        end
        if in_code_fence || (previous_blank && line.match?(/\A(    |\t)/))
          result << line
          next
        end
        if line.strip.empty?
          result << line
          previous_blank = true
          next
        end
        result << escape_inline(line)
        previous_blank = false
      end
      result
    end

    def escape_inline(line)
      # Balanced-length code spans (` or `` or more) are kept verbatim;
      # everything outside them is escaped.
      result = +""
      pos = 0
      line.to_enum(:scan, /(`+)([^\n]*?)\1/).each do
        span = Regexp.last_match
        result << escape_text(line[pos...span.begin(0)])
        result << span[0]
        pos = span.end(0)
      end
      result << escape_text(line[pos..])
      result
    end

    def escape_text(text)
      text.gsub(/&(?!(?:[a-zA-Z][a-zA-Z0-9]*|#\d+|#x[0-9a-fA-F]+);)/, "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
    end
  end
end
