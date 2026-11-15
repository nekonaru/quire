<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/quire-mark-dark.svg" />
    <img src="assets/quire-mark-light.svg" alt="Quire logo" width="120" />
  </picture>
  <h1>Quire: Static Site Generator</h1>
  <p><b>Turn a folder of Markdown files into a ready-to-deploy static site,<br/>
  with tags, pagination, feeds, and two themes built in.</b></p>

  <a href="https://github.com/nekonaru/quire/releases"><img src="https://img.shields.io/github/v/release/nekonaru/quire?style=flat-square&color=blue" alt="Release" /></a>
  <a href="https://github.com/nekonaru/quire/actions/workflows/ci.yml"><img src="https://github.com/nekonaru/quire/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <img src="https://img.shields.io/badge/Ruby-%E2%89%A53.2-CC342D?style=flat-square&logo=ruby&logoColor=white" alt="Ruby" />
  <img src="https://img.shields.io/badge/Platform-Windows%20%C2%B7%20macOS%20%C2%B7%20Linux-333333?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square" alt="Status" />
</div>

<br />

**English** | [Bahasa Indonesia](README.id.md)

> [!NOTE]
> Quire builds your site from Markdown you already have. There is no database, no account, and no JavaScript required on the reader's side.

---

## Table of Contents

- [About](#about)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Front matter](#front-matter)
- [Project Structure](#project-structure)
- [Development](#development)
- [Testing](#testing)
- [Security](#security)
- [Continuous Integration](#continuous-integration)
- [FAQ](#faq)
- [Author](#author)
- [License](#license)

---

## About

**Quire** takes a folder of Markdown files with YAML front matter and turns it into a static site (HTML and CSS) that you can deploy to GitHub Pages, Netlify, or Cloudflare Pages. It ships with two built-in themes, `blog` and `portfolio`, and the whole build pipeline is small enough to read in an afternoon.

> _"Markdown in, site out. No JavaScript, no magic."_

Live demo: https://nekonaru.github.io/quire/ (the `examples/demo` site in this repository, deployed by GitHub Actions on every change).

---

## Features

### Content

| Feature | Description |
|---------|-------------|
| **Markdown with GFM** | Tables, fenced code blocks, footnotes, and strikethrough, rendered by kramdown |
| **Syntax highlighting** | Code blocks highlighted by Rouge, themes included in both built-in themes |
| **YAML front matter** | `title`, `date`, `tags`, `draft`, `layout`, `slug`, and `description` per post or page |
| **Drafts and future posts** | Excluded from builds by default; include them with `--drafts` or `--future` |

### Site building

| Feature | Description |
|---------|-------------|
| **Tags** | Automatic tag pages at `/tags/<tag>/`, plus a tag index at `/tags/` |
| **Pagination** | Home page pagination at `/page/2/`, `/page/3/`, and so on |
| **Atom feed** | `feed.xml` with the 20 most recent posts |
| **Sitemap and robots** | `sitemap.xml` and `robots.txt` generated on every build |
| **Open Graph meta** | `og:title`, `og:description`, `og:url`, and canonical links in both themes |
| **Incremental builds** | Unchanged input means no rebuild; force one with `quire build --force` |

### Themes

| Feature | Description |
|---------|-------------|
| **Two built-in themes** | `blog` for long-form reading with pagination, `portfolio` with hero and project grid |
| **One-line theme switch** | Change `theme: blog` to `theme: portfolio` in `quire.yml` and rebuild |
| **File-level overrides** | Override any single theme layout or asset from your site's `themes/<name>/` directory |
| **System dark mode** | Both themes follow `prefers-color-scheme`; no toggle, no JavaScript |

### Tooling

| Feature | Description |
|---------|-------------|
| **Live reload** | `quire serve` rebuilds on change and reloads the browser automatically |
| **Custom 404** | Every build writes `404.html` for hosts that use it |
| **Data files** | `data/*.yml` is available in templates as `site.data` (the portfolio theme reads `projects.yml`) |
| **Clear errors** | Broken front matter, bad YAML, or a missing layout fails with the file and line number |

---

## Requirements

| Dependency | Minimum Version | Notes |
|------------|-----------------|-------|
| **Ruby** | 3.2 | Required to install and run Quire |
| **Git** | any recent | Required only to install from GitHub |

> [!TIP]
> You do not need to build anything. Option A installs the prebuilt gem in two commands.

### Never used a terminal? Start here

<details>
<summary><b>How to open a terminal on Windows</b></summary>

1. Press the **Windows** key, type `PowerShell`, then press **Enter**
2. A window opens. That is where you type commands
3. Every command in this guide is typed in that window, followed by **Enter**

</details>

<details>
<summary><b>How to open a terminal on macOS</b></summary>

1. Press **Cmd + Space**, type `Terminal`, then press **Enter**
2. A window opens. That is where you type commands
3. Every command in this guide is typed in that window, followed by **Enter**

</details>

<details>
<summary><b>How to open a terminal on Linux</b></summary>

1. Press **Ctrl + Alt + T**, or open your application launcher and type `Terminal`
2. A window opens. That is where you type commands
3. Every command in this guide is typed in that window, followed by **Enter**

</details>

---

## Installation

### Option A: Download the prebuilt gem (easiest)

1. Open https://github.com/nekonaru/quire/releases/latest
2. Download `quire-0.1.0.gem` from Assets
3. Install it:

```bash
gem install ./quire-0.1.0.gem
quire version
```

Then create your first site:

```bash
quire new site mysite
cd mysite
quire build
quire serve
```

Open http://localhost:4000 in your browser.

### Option B: Build from source (for development / to read or change the code)

#### 1. Get the project code

<details>
<summary><b>I have Git installed</b></summary>

```bash
git clone https://github.com/nekonaru/quire.git
cd quire
```

</details>

<details>
<summary><b>I don't have Git</b></summary>

1. Open the repository page on GitHub
2. Click the green **`Code`** button, choose **`Download ZIP`**
3. Extract the ZIP to a folder of your choice
4. In the terminal, go into the extracted folder, for example:

```bash
cd Downloads/quire-main
```

</details>

#### 2. Install dependencies and verify

```bash
bundle install
bundle exec rspec
```

> [!IMPORTANT]
> `bundle exec rspec` must pass the full suite before you build.

#### 3. Build and install the gem

```bash
gem build quire.gemspec
gem install ./quire-0.1.0.gem
quire version
```

---

## Usage

### First build

1. Create a site with `quire new site mysite`
2. `cd mysite`
3. `quire serve`
4. Open http://localhost:4000

> [!NOTE]
> `quire serve` rebuilds automatically. Edit any file in `content/`, `data/`, `static/`, or `themes/` and the browser refreshes on its own.

### Everyday commands

```bash
quire new post "My post title"    # create content/posts/2026-11-15-my-post-title.md
quire new page "Uses"             # create content/pages/uses.md
quire build                       # build into public/
quire build --drafts --future     # include drafts and future-dated posts
quire build --force               # ignore the incremental cache
quire serve                       # build, serve at :4000, live reload
quire serve --port 8080           # serve on a different port
quire clean                       # remove public/ and .quire-cache.json
quire version                     # print the version
```

### Deploy to GitHub Pages

1. Push your site to a GitHub repository
2. In the repository: **Settings > Pages > Source**, pick **GitHub Actions**, or publish the `public/` folder with a workflow such as `actions/deploy-pages`
3. Set `base_url` in `quire.yml` to your Pages URL (for example `https://<user>.github.io/<repo>`), then rebuild

---

## Configuration

Everything lives in `quire.yml` at the site root:

```yaml
title: My Site
description: What this site is about
author: Your Name
base_url: https://example.com   # no trailing slash; needed for feeds and sitemap
theme: blog                     # blog or portfolio (or a theme in themes/)
posts_per_page: 10
email: me@example.com           # shown on the portfolio contact button
menu:
  - title: Home
    url: /
  - title: About
    url: /about/
social:
  github: yourhandle
markdown:
  allow_html: false             # set true to pass raw HTML through
```

| Key | Default | Meaning |
|-----|---------|---------|
| `title` | `Quire Site` | Site title, used in the header and `<title>` |
| `description` | `""` | Site description, used in meta tags |
| `author` | `""` | Shown in the footer and feeds |
| `base_url` | `""` | Absolute base URL, no trailing slash |
| `theme` | `blog` | Built-in theme or one in `themes/<name>/` |
| `posts_per_page` | `10` | Posts per index page |
| `menu` | `[]` | Nav bar entries with `title` and `url` |
| `markdown.allow_html` | `false` | `true` lets raw HTML in Markdown through |

---

## Front matter

Posts live in `content/posts/`, pages in `content/pages/`. Every Markdown file starts with front matter:

```markdown
---
title: My post
date: 2026-11-15
tags:
  - ruby
  - meta
draft: false
slug: my-post
description: One line shown in feeds and meta tags
layout: post
---

Body in Markdown.
```

| Key | Required | Meaning |
|-----|----------|---------|
| `title` | no | Defaults to the file name; used in `<title>` and lists |
| `date` | posts: recommended | `YYYY-MM-DD`; controls ordering. Pages have no date |
| `tags` | no | List of tag names; drives tag pages |
| `draft` | no | `true` hides the file from builds unless `--drafts` |
| `slug` | no | URL slug; defaults to the file name |
| `description` | no | One-line summary for feeds, meta tags, and excerpts |
| `layout` | no | Layout name; defaults to `post` or `page` |

Files named `YYYY-MM-DD-title.md` get the date and slug from the name when front matter omits them.

---

## Project Structure

```
quire/
├── exe/quire                   # CLI entry point
├── lib/quire/
│   ├── cli.rb                  # thor commands
│   ├── config.rb               # quire.yml loading and validation
│   ├── document.rb             # post/page model (front matter + body)
│   ├── front_matter.rb         # YAML front matter parser
│   ├── markdown.rb             # kramdown + rouge renderer
│   ├── site.rb                 # site model: posts, pages, tags, data
│   ├── builder.rb              # build pipeline
│   ├── renderer.rb             # ERB rendering with layouts and partials
│   ├── theme.rb                # theme resolution and overrides
│   ├── paginator.rb            # home page pagination
│   ├── feed.rb                 # Atom feed
│   ├── sitemap.rb              # sitemap.xml
│   └── server.rb               # WEBrick server + live reload
├── themes/
│   ├── blog/                   # built-in blog theme
│   └── portfolio/              # built-in portfolio theme
├── templates/new_site/         # scaffold for `quire new site`
├── examples/demo/              # example site used by integration tests
├── spec/                       # RSpec suite
├── docs/decisions.md           # design decisions
├── README.md                   # documentation (English)
└── README.id.md                # documentation (Bahasa Indonesia)
```

---

## Development

### Adding a new theme

1. Create `themes/<name>/theme.yml` in your site, or copy `themes/blog/` from this repository
2. Add layouts: `base.html.erb` is the skeleton; everything else (`post`, `page`, `index`, `tag`, `tags`, `404`) is wrapped in it
3. Put CSS and other assets in `themes/<name>/assets/`; they are copied to `public/assets/`
4. Set `theme: <name>` in `quire.yml` and run `quire build`

Built-in themes use no framework and no JavaScript. Follow the same rules in yours.

### Overriding a single theme file

Copy the file you want to change from the theme into `themes/<name>/` in your site, keeping the same relative path. Only that file is overridden; everything else falls back to the theme.

Example: override only the 404 page of the blog theme in your site:

```
mysite/themes/blog/layouts/404.html.erb
```

### Adding a user-facing string

Quire's CLI messages are in English (see `lib/quire/cli.rb`). Themes use plain English markup; there is no string catalog to maintain.

---

## Testing

```bash
bundle exec rspec
bundle exec rubocop
```

| Check | Requirement |
|-------|-------------|
| `bundle exec rspec` | Must pass the full suite |
| `bundle exec rubocop` | Must report no offenses |

Lints are enforced through `.rubocop.yml`. The demo site at `examples/demo/` is used as an integration test: the test suite builds it and checks the output structure, feeds, and sitemap.

---

## Security

Quire builds static files from your own Markdown; it never runs a database or an application server in production. Raw HTML in Markdown is escaped by default, so a post cannot inject markup into the site. Secrets are scanned in CI, and dependency review happens through the release checklist. To report a vulnerability, see [`SECURITY.md`](SECURITY.md).

> [!NOTE]
> Please report vulnerabilities privately via GitHub security advisories, not as public issues.

---

## Continuous Integration

| Workflow | Purpose |
|----------|---------|
| `ci.yml` | RuboCop, RSpec (Ruby 3.2 and 3.4 on Linux, Windows, macOS), gem build, example site build, secret scan on every push and pull request |
| `release.yml` | Builds the gem and drafts a GitHub release with the changelog notes on `v*` tags |
| `deploy-demo.yml` | Builds the demo site and deploys it to GitHub Pages on every push to main that touches the demo or the generator |

The release is tagged only after CI is green on the default branch.

---

## FAQ

<details>
<summary><b>How do I deploy to GitHub Pages?</b></summary>

Set `base_url` to your Pages URL, commit `public/` or use a deploy workflow, and enable Pages in the repository settings. See Usage above.

</details>

<details>
<summary><b>How do I switch from the blog theme to the portfolio theme?</b></summary>

Change `theme: blog` to `theme: portfolio` in `quire.yml` and rebuild. Content does not change.

</details>

<details>
<summary><b>Where do project grid entries come from?</b></summary>

`data/projects.yml` in your site. Each entry is a `name`, `description`, `url` (optional), and `tech` (optional).

</details>

<details>
<summary><b>Can I add raw HTML to a post?</b></summary>

Set `markdown.allow_html: true` in `quire.yml`. By default, raw HTML is escaped.

</details>

<details>
<summary><b>Why don't drafts show up?</b></summary>

Drafts (and posts dated in the future) are excluded unless you pass `--drafts` or `--future` to `quire build` or `quire serve`.

</details>

---

## Author

<div align="center">

| [![Nicolas Dwi Dharma](https://github.com/nekonaru.png?size=100)](https://github.com/nekonaru) |
|:---:|
| **Nicolas Dwi Dharma** |
| [github.com/nekonaru](https://github.com/nekonaru) |

</div>

---

## License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.
