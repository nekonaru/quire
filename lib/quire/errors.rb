# frozen_string_literal: true

module Quire
  # Error raised for any user-facing Quire failure. Carries the offending file
  # and line so messages can say exactly where the problem is.
  class Error < StandardError
    attr_reader :file, :line

    def initialize(message, file: nil, line: nil)
      @file = file
      @line = line
      super(format_message(message))
    end

    private

    def format_message(message)
      location = +""
      location << file.to_s if file
      location << ":#{line}" if line
      location.empty? ? message : "#{location}: #{message}"
    end
  end
end
