# frozen_string_literal: true

module Quire
  # Polls a list of files for changes by mtime and runs the given block when
  # any of them change. Used for quire.yml, which listen cannot watch.
  class ConfigPoller
    def initialize(files, interval: 1, &on_change)
      @files = files
      @interval = interval
      @on_change = on_change
    end

    def start
      return if @files.empty?

      Thread.new do
        stamps = @files.to_h { |f| [f, File.mtime(f)] }
        loop do
          sleep @interval
          next unless stamps.any? { |f, stamp| File.mtime(f) != stamp }

          @files.each { |f| stamps[f] = File.mtime(f) }
          @on_change.call
        end
      rescue StandardError
        retry
      end
    end
  end
end
