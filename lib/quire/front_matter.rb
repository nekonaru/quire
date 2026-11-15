# frozen_string_literal: true

require "yaml"
require_relative "errors"

module Quire
  # Splits a Markdown file into YAML front matter and body.
  # Front matter format:
  #   ---
  #   title: Hello
  #   ---
  #   Body text
  module FrontMatter
    DATA_SEPARATOR = "---"

    module_function

    # Returns [attributes, body, front_matter_line]
    def parse(text, file: nil)
      text = text.delete_prefix("\uFEFF")
      lines = text.lines
      first = lines.first
      return [{}, text, nil] unless first && first.strip == DATA_SEPARATOR

      closing_index = lines[1..]&.index { |l| l.strip == DATA_SEPARATOR }
      raise Error.new("front matter opening '---' has no closing '---'", file: file, line: 1) unless closing_index

      closing_index += 1 # adjust for the slice offset
      yaml_block = lines[1...closing_index].join
      body = lines[(closing_index + 1)..]&.join || ""

      attributes = safe_load(yaml_block, file)
      [attributes, body, 2]
    end

    def safe_load(yaml_block, file)
      data = YAML.safe_load(yaml_block, permitted_classes: [Date, Time, DateTime, Symbol], aliases: false)
      return {} if data.nil?

      raise Error.new("front matter must be a YAML mapping (key: value), got #{data.class}", file: file, line: 1) unless data.is_a?(Hash)

      data.transform_keys(&:to_s)
    rescue Psych::SyntaxError => e
      raise Error.new("invalid YAML in front matter: #{e.message.strip}", file: file, line: e.line ? e.line + 1 : nil)
    rescue Psych::Exception => e
      raise Error.new("invalid YAML in front matter: #{e.message.strip}", file: file, line: 1)
    end
  end
end
