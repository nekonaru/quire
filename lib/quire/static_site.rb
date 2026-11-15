# frozen_string_literal: true

require_relative "http_helpers"

module Quire
  # Serves the built site for `quire serve`: pretty URLs, redirects,
  # 404s, content types and the live-reload snippet injection.
  class StaticSite
    def initialize(public_dir)
      @public_dir = public_dir
    end

    # Returns [status, content_type, body, headers].
    def handle(request_path)
      relative = request_path.sub(%r{\A/+}, "")

      redirect = redirect_target(request_path, relative)
      return [301, "text/html", "", { "Location" => redirect }] if redirect

      candidate = File.join(@public_dir, relative)
      candidate = File.join(candidate, "index.html") if directory_request?(request_path, relative)

      return serve_not_found if !HttpHelpers.safe_within?(@public_dir, candidate) || !File.file?(candidate)

      serve_file(candidate)
    end

    private

    def directory_request?(request_path, relative)
      request_path.end_with?("/") || File.extname(relative).empty?
    end

    # 301 to the trailing-slash form when a directory with index.html exists.
    def redirect_target(request_path, relative)
      return nil if request_path.end_with?("/") || !File.extname(relative).empty?

      dir_candidate = File.join(@public_dir, relative)
      index = File.join(dir_candidate, "index.html")
      return nil unless HttpHelpers.safe_within?(@public_dir, dir_candidate) && File.file?(index)

      "#{request_path}/"
    end

    def serve_file(candidate)
      body = File.binread(candidate)
      body = HttpHelpers.inject_reload(body) if candidate.end_with?(".html")
      [200, HttpHelpers.content_type(candidate), body, {}]
    end

    def serve_not_found
      not_found = File.join(@public_dir, "404.html")
      body = if File.exist?(not_found)
               HttpHelpers.inject_reload(File.read(not_found))
             else
               "<h1>404 Not Found</h1>"
             end
      [404, "text/html", body, {}]
    end
  end
end
