# Design Decisions

Short record of the decisions that shaped Quire, in the order they were made.

## D1. ERB over a template gem

Layouts and partials use ERB from the standard library. No new dependency, no
new syntax to learn, and `h()` is explicit in templates. The cost is that
templates must call `h()` themselves; the built-in themes do this everywhere
for author content.

## D2. Theme resolution: site wins, file by file

A theme name is resolved in two places, in order:

1. `<site>/themes/<name>/` (site can override single files, e.g. only `404.html.erb`)
2. `<gem>/themes/<name>/` (built-in)

Per the PRD, a site can override individual theme files without forking the
whole theme. If the site directory does not exist, the built-in theme is used
as-is.

## D3. Layout wrapping via a `base.html.erb` convention

`base.html.erb` is the HTML skeleton. Every other layout is rendered first,
then wrapped in `base` with the inner HTML as `content`. No layout front
matter to parse, one rule to remember, and a layout can opt out by being named
`base` itself.

## D4. Raw HTML in Markdown is escaped by default

`markdown.allow_html: false` (default) escapes `&`, `<` and `>` outside code
blocks before rendering, so a Markdown file cannot inject markup into the
site. `markdown.allow_html: true` passes raw HTML through unchanged. This is a
config knob, matching the PRD requirement that escaping is configurable.

## D5. Generated pages are virtual documents

The home page, tag pages, the tag index and the 404 page are rendered with the
same layout pipeline as real posts, using a small `PageData` struct that
mimics the `Document` interface (`title`, `description`, `url`, `date`,
`tags`). Templates never special-case generated pages.

## D6. Simple incremental builds via a content hash

FR-11 asked for "build incremental sederhana (hash konten)". Quire hashes all
inputs (config, content, data, static, theme layouts and assets) into
`.quire-cache.json`. If the hash matches and `public/` exists, the build is
skipped entirely. `quire build --force` rebuilds regardless. This is
intentionally simple: no per-file cache, no partial re-rendering.

## D7. Live reload over polling

FR-12 asks for polling-based live reload. `quire serve` serves `public/`
through WEBrick, injects a small polling script into served HTML (never into
the files on disk), and bumps a build version when a rebuild succeeds. The
browser polls `/__quire/version` every second and reloads when it changes.
File watching uses the `listen` gem.

## D8. Feeds and sitemaps need `base_url`

Atom and sitemap require absolute URLs. If `base_url` is empty, `robots.txt`
omits the `Sitemap:` line and the builder prints a warning; both files are
still written with relative URLs. For the demo site, `base_url` is set.

## D9. Atomic-ish output by cleaning first

The builder removes `public/` and rebuilds from scratch on every run. A failed
build can leave `public/` partial; rerun after fixing the error listed with
its file and line. The incremental cache (D6) avoids the cost when inputs are
unchanged.

## D10. Pagination URLs

Home pagination lives at `/page/2/`, `/page/3/`, ... and the first page is
`/`. Post URLs are `/posts/<slug>/`, page URLs are `/<slug>/`, tags are
`/tags/<slug>/`. Pretty URLs everywhere; no query strings.

## D11. No dark mode toggle, respect system preference

Both themes ship CSS variables with `@media (prefers-color-scheme: dark)`
instead of a JavaScript toggle. The output has no required JavaScript.
