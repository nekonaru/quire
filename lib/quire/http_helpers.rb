# frozen_string_literal: true

module Quire
  # Shared helpers for the local development server: content types, the live
  # reload snippet injected into served HTML, and path safety.
  module HttpHelpers
    LIVE_RELOAD_SCRIPT = <<~JS
      <script>
        (function () {
          var current = null;
          setInterval(function () {
            fetch('/__quire/version', {cache: 'no-store'})
              .then(function (r) { return r.json(); })
              .then(function (data) {
                if (current === null) { current = data.version; return; }
                if (data.version !== current) { window.location.reload(); }
              })
              .catch(function () {});
          }, 1000);
        })();
      </script>
    JS

    CONTENT_TYPES = {
      ".html" => "text/html",
      ".css" => "text/css",
      ".js" => "application/javascript",
      ".xml" => "application/xml",
      ".txt" => "text/plain",
      ".svg" => "image/svg+xml",
      ".png" => "image/png",
      ".jpg" => "image/jpeg",
      ".jpeg" => "image/jpeg",
      ".gif" => "image/gif",
      ".webp" => "image/webp",
      ".ico" => "image/x-icon",
      ".woff2" => "font/woff2",
      ".pdf" => "application/pdf"
    }.freeze

    module_function

    def content_type(path)
      CONTENT_TYPES.fetch(File.extname(path).downcase, "application/octet-stream")
    end

    def inject_reload(html)
      return html if html.include?("/__quire/version")

      html.sub("</body>", "#{LIVE_RELOAD_SCRIPT}</body>")
    end

    def safe_within?(base, candidate)
      expanded = File.expand_path(candidate)
      expanded == base || expanded.start_with?(File.expand_path(base) + File::SEPARATOR)
    end
  end
end
