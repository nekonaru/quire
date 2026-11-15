# Changelog

All notable changes to Quire are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.1.0

First public release of Quire, a static site generator written in Ruby.

## New features

- **Markdown pipeline.** kramdown with GFM input renders posts; tables, fenced code blocks with Rouge syntax highlighting, and footnotes all work out of the box.
- **YAML front matter.** Posts and pages take `title`, `date`, `tags`, `draft`, `layout`, `slug`, and `description`. Invalid front matter fails the build with the file and line number.
- **Two built-in themes.** `blog` for a comfortable long-form reading list with tags and pagination, `portfolio` for a personal site with a hero and a project grid driven by `data/projects.yml`. Switch themes with one line in `quire.yml`.
- **CLI.** `quire new site`, `quire new post`, `quire new page`, `quire build`, `quire serve`, `quire clean`, and `quire version`.
- **Local server with live reload.** `quire serve` rebuilds on file changes and the browser refreshes automatically (polling, no JavaScript build step).
- **Feeds and discovery.** Atom feed at `feed.xml`, `sitemap.xml`, `robots.txt`, and Open Graph plus canonical meta tags in both themes.
- **Drafts and future posts.** Excluded by default; included with `--drafts` and `--future`.
- **Incremental builds.** Unchanged input means no rebuild; `quire build --force` overrides.
- **Theme overrides.** A site can override any single theme file (layout or asset) by placing a file in `themes/<name>/`, without forking the theme.

## Usage

Install from GitHub with Ruby 3.2 or newer:

```bash
gem install --git https://github.com/nekonaru/quire.git
quire new site mysite
cd mysite
quire build
quire serve
```

Or build the gem from source with `gem build quire.gemspec` after `gem install --git` fails. See the README for the full tutorial.
