# frozen_string_literal: true

module Quire
  # Polls a list of files for changes by mtime and yields when any of them
  # changes. A missing file counts as a change, so a deleted quire.yml still
  # triggers a rebuild (which then reports the missing file as an error).
  # Used for quire.yml, which listen cannot watch.
  class ConfigPoller
    def initialize(files, interval: 1, &on_change)
      @files = files
      @interval = interval
      @on_change = on_change
    end

    def start
      return if @files.empty?

      Thread.new do
        stamps = snapshot_stamps
        loop do
          sleep @interval
          begin
            changed = changed?(stamps)
            stamps = snapshot_stamps
            @on_change.call if changed
          rescue StandardError => e
            warn "Quire file watcher: #{e.message}"
          end
        end
      end
    end

    private

    def snapshot_stamps
      @files.to_h { |file| [file, (File.mtime(file) if File.exist?(file))] }
    end

    def changed?(stamps)
      stamps.any? do |file, stamp|
        current = File.exist?(file) ? File.mtime(file) : nil
        current != stamp
      end
    end
  end
end
