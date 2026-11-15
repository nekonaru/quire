# frozen_string_literal: true

require "thor"
require "fileutils"
require "date"
require_relative "builder"
require_relative "errors"
require_relative "server"
require_relative "slug"
require_relative "version"

module Quire
  # Command line interface.
  #
  #   quire new site NAME    Create a new site in ./NAME
  #   quire new post TITLE   Create a new post with front matter
  #   quire new page TITLE   Create a new page with front matter
  #   quire build            Build the site into public/
  #   quire serve            Serve the site locally with live reload
  #   quire clean            Remove public/ and the cache
  #   quire version          Print the Quire version
  class CLI < Thor
    TEMPLATE_DIR = File.expand_path("../../templates/new_site", __dir__)

    def self.exit_on_failure? = true

    desc "new SUBCOMMAND ARGS", "Create a site, post, or page (site NAME | post TITLE | page TITLE)"
    option :draft, type: :boolean, default: false, desc: "Mark the post or page as a draft"
    option :path, type: :string, default: ".", desc: "Site root for posts, pages, and site creation"
    def new(subcommand, *args)
      case subcommand
      when "site"
        name = args.shift or raise Thor::Error, "usage: quire new site NAME"
        create_site(name)
      when "post", "page"
        title = args.join(" ")
        raise Thor::Error, "usage: quire new #{subcommand} TITLE" if title.strip.empty?

        create_with_front_matter(subcommand == "post" ? "content/posts" : "content/pages",
                                 title, draft: options[:draft], root: options[:path])
      else
        raise Thor::Error, "unknown subcommand #{subcommand.inspect} (expected: site, post, page)"
      end
    end

    desc "build", "Build the site into public/"
    option :path, type: :string, default: ".", desc: "Site root (defaults to the current directory)"
    option :drafts, type: :boolean, default: false, desc: "Include draft posts"
    option :future, type: :boolean, default: false, desc: "Include posts dated in the future"
    option :force, type: :boolean, default: false, desc: "Rebuild even if inputs are unchanged"
    def build
      result = Builder.new(options[:path], drafts: options[:drafts], future: options[:future], force: options[:force]).build
      result.warnings.each { |warning| warn "Warning: #{warning}" }
      puts result.summary
    end

    desc "serve", "Serve the site locally with live reload"
    option :path, type: :string, default: ".", desc: "Site root (defaults to the current directory)"
    option :port, type: :numeric, default: 4000, desc: "Port to listen on"
    option :drafts, type: :boolean, default: false, desc: "Include draft posts"
    option :future, type: :boolean, default: false, desc: "Include posts dated in the future"
    def serve
      Server.new(options[:path], port: options[:port], drafts: options[:drafts], future: options[:future]).start
    end

    desc "clean", "Remove the build output (public/) and the cache"
    option :path, type: :string, default: ".", desc: "Site root (defaults to the current directory)"
    def clean
      root = File.expand_path(options[:path])
      FileUtils.rm_rf(File.join(root, "public"))
      FileUtils.rm_f(File.join(root, Builder::CACHE_FILE))
      puts "Removed public/ and #{Builder::CACHE_FILE}"
    end

    desc "version", "Print the Quire version"
    def version
      puts "quire #{VERSION}"
    end
    map %w[-v --version] => :version

    def self.start(given_args = ARGV, config = {})
      super
    rescue Errno::ENOENT, Error, Thor::Error => e
      warn "Error: #{e.message}"
      exit(1)
    end

    private

    def create_site(name)
      target = File.expand_path(name)
      raise Thor::Error, "directory already exists: #{target}" if File.exist?(target)

      FileUtils.mkdir_p(target)
      Dir.children(TEMPLATE_DIR).each do |entry|
        FileUtils.cp_r(File.join(TEMPLATE_DIR, entry), target)
      end
      puts "Created a new site in #{target}"
      puts "Next steps:"
      puts "  cd #{name}"
      puts "  quire build"
      puts "  quire serve"
    end

    def create_with_front_matter(relative_dir, title, draft:, root:)
      root = File.expand_path(root)
      slug = Slug.slugify(title)
      raise Thor::Error, "could not derive a slug from #{title.inspect}" if slug.empty?

      dir = File.join(root, relative_dir)
      FileUtils.mkdir_p(dir)

      file_name = relative_dir.include?("posts") ? "#{Date.today}-#{slug}.md" : "#{slug}.md"
      target = File.join(dir, file_name)
      raise Thor::Error, "file already exists: #{target}" if File.exist?(target)

      front_matter = <<~YAML
        ---
        title: #{title}
        date: #{Date.today}
        tags: []
        draft: #{draft}
        description: ""
        ---

        Write your content here.
      YAML
      File.write(target, front_matter)
      puts "Created #{target}"
    end
  end
end
