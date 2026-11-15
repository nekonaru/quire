# frozen_string_literal: true

require "fileutils"
require "listen"
require "json"
require "webrick"
require_relative "builder"
require_relative "config_poller"
require_relative "errors"
require_relative "http_helpers"
require_relative "static_site"

module Quire
  # Local development server. Serves the built site and reloads the browser
  # when files change. Reload detection: the watcher rebuilds on change and
  # bumps a build version; the injected script in served HTML polls
  # /__quire/version every second and reloads when it sees a new one.
  class Server
    WATCHED_DIRS = %w[content data static themes].freeze
    WATCHED_FILES = %w[quire.yml].freeze

    def initialize(root, port: 4000, drafts: false, future: false)
      @root = File.expand_path(root)
      @port = port
      @drafts = drafts
      @future = future
      @version = 0
      @mutex = Mutex.new
    end

    def start
      build!

      server = WEBrick::HTTPServer.new(Port: @port, BindAddress: "127.0.0.1", AccessLog: [], Logger: WEBrick::Log.new(File::NULL))
      mount_version_endpoint(server)
      mount_site(server)

      listener = start_listener
      trap("INT") { server.shutdown }
      trap("TERM") { server.shutdown }

      puts "Quire serving #{@root} at http://127.0.0.1:#{@port} (Ctrl+C to stop)"
      server.start
    ensure
      listener&.stop
    end

    private

    def build!
      Builder.new(@root, drafts: @drafts, future: @future, force: true).build
      @mutex.synchronize { @version += 1 }
    rescue Error => e
      warn "Build failed: #{e.message}"
      raise
    end

    def rebuild_quietly
      build!
      puts "Rebuilt at #{Time.now.strftime('%H:%M:%S')}"
    rescue Error
      # keep serving the last good build
      nil
    end

    def start_listener
      paths = WATCHED_DIRS.map { |d| File.join(@root, d) }.select { |d| Dir.exist?(d) }
      pattern = /\.(md|yml|yaml|css|js|html|png|jpg|jpeg|gif|svg|webp|ico|txt|xml)$/i
      listener = Listen.to(*paths, only: pattern) { rebuild_quietly }
      start_config_poll
      listener.start
      listener
    end

    def start_config_poll
      files = WATCHED_FILES.map { |f| File.join(@root, f) }.select { |f| File.exist?(f) }
      ConfigPoller.new(files) { rebuild_quietly }.start
    end

    def mount_version_endpoint(server)
      server.mount_proc("/__quire/version") do |req, res|
        unless HttpHelpers.local_host?(req["Host"])
          res.status = 403
          res["Content-Type"] = "text/plain"
          res.body = "Forbidden"
          next
        end

        res.status = 200
        res["Content-Type"] = "application/json"
        res["Cache-Control"] = "no-store"
        res.body = JSON.generate({ version: @mutex.synchronize { @version } })
      end
    end

    def mount_site(server)
      static_site = StaticSite.new(File.join(@root, "public"))
      server.mount_proc("/") do |req, res|
        unless HttpHelpers.local_host?(req["Host"])
          res.status = 403
          res["Content-Type"] = "text/plain"
          res.body = "Forbidden"
          next
        end

        status, content_type, body, headers = static_site.handle(req.path)
        res.status = status
        res["Content-Type"] = content_type
        headers.each { |key, value| res[key] = value }
        res.body = body
      end
    end
  end
end
