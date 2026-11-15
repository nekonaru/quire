# Changelog

All notable changes to Quire are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.1.1

Patch release fixing a title-encoding defect and several robustness issues.

## Bug fixes

- **Mojibake in page titles.** The separator between a page title and the site title was double-encoded and displayed as "Â·" on every non-home page in both themes.
- **Indented code blocks.** HTML inside 4-space indented code blocks was double-escaped, so code samples displayed raw entity text instead of markup.
- **Non-UTF-8 environments.** The slug generator no longer crashes when file names or content use a non-UTF-8 locale.
- **Front matter parsing.** The YAML block no longer includes the closing `---` line, removing a latent parsing trap.
- **posts_per_page validation.** Float values are rejected with a clear error instead of being silently truncated to an integer.
- **`quire new site` argument count.** Extra arguments now produce a usage error instead of being silently ignored.

## Improvements

- **README accuracy.** The Security section now describes what CI actually checks instead of a nonexistent release checklist.

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

Install from GitHub Releases with Ruby 3.2 or newer:

```bash
curl -LO https://github.com/nekonaru/quire/releases/download/v0.1.0/quire-0.1.0.gem
gem install ./quire-0.1.0.gem
quire new site mysite
cd mysite
quire build
quire serve
```

Or build the gem from source with `gem build quire.gemspec` and `gem install ./quire-0.1.0.gem`. See the README for the full tutorial.
