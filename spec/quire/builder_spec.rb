# frozen_string_literal: true

RSpec.describe Quire::Builder do
  let(:output_dir) { File.join(Dir.mktmpdir("quire-out"), "public") }

  it "builds the demo site with all expected artifacts" do
    root = copy_site!("demo")
    result = described_class.new(root, output_dir: output_dir, force: true).build

    expect(result.posts).to eq(12)
    expect(result.pages).to eq(3)
    expect(result.tags).to be >= 3

    index = File.read(File.join(output_dir, "index.html"))
    expect(index).to include("Shipping Quire v0.1")
    expect(index).to include("Projects")

    post_page = File.join(output_dir, "posts", "shipping-quire-v0-1", "index.html")
    expect(File.read(post_page)).to include("<h1")

    expect(File.exist?(File.join(output_dir, "page", "2", "index.html"))).to be(true)
    expect(File.exist?(File.join(output_dir, "page", "3", "index.html"))).to be(true)
    expect(File.exist?(File.join(output_dir, "tags", "index.html"))).to be(true)
    expect(File.exist?(File.join(output_dir, "tags", "ruby", "index.html"))).to be(true)
    expect(File.exist?(File.join(output_dir, "feed.xml"))).to be(true)
    expect(File.exist?(File.join(output_dir, "sitemap.xml"))).to be(true)
    expect(File.exist?(File.join(output_dir, "robots.txt"))).to be(true)
    expect(File.exist?(File.join(output_dir, "404.html"))).to be(true)
    expect(File.exist?(File.join(output_dir, "assets", "style.css"))).to be(true)

    sitemap = File.read(File.join(output_dir, "sitemap.xml"))
    expect(sitemap).to include("https://nekonaru.github.io/quire-demo/posts/shipping-quire-v0-1/")
  end

  it "builds the new site template with the blog theme" do
    root = File.join(Dir.mktmpdir("quire-new-site"), "site")
    FileUtils.mkdir_p(root)
    template = File.expand_path("../../templates/new_site", __dir__)
    Dir.children(template).each { |entry| FileUtils.cp_r(File.join(template, entry), root) }

    result = described_class.new(root, output_dir: output_dir, force: true).build
    expect(result.posts).to eq(1)
    expect(result.pages).to eq(1)

    index = File.read(File.join(output_dir, "index.html"))
    expect(index).to include("Hello, Quire")
  end

  it "skips drafts and future posts unless flags are given" do
    root = copy_site!("demo")
    drafts_dir = File.join(root, "content", "posts")
    File.write(File.join(drafts_dir, "2026-11-10-secret-draft.md"),
               "---\ntitle: Secret Draft\ndraft: true\n---\nHidden\n")
    File.write(File.join(drafts_dir, "2099-01-01-far-future.md"),
               "---\ntitle: Far Future\ndate: 2099-01-01\n---\nNot yet\n")

    plain = described_class.new(root, output_dir: output_dir, force: true).build
    plain_index = File.read(File.join(output_dir, "index.html"))
    expect(plain_index).not_to include("Secret Draft")
    expect(plain_index).not_to include("Far Future")

    with_flags = described_class.new(root, output_dir: output_dir, drafts: true, future: true, force: true).build
    index = File.read(File.join(output_dir, "index.html"))
    expect(index).to include("Secret Draft")
    expect(index).to include("Far Future")
    expect(with_flags.posts).to eq(plain.posts + 2)
  end

  it "caches builds and reports no changes on a second run" do
    root = copy_site!("demo")
    described_class.new(root, output_dir: output_dir, force: true).build
    cached = described_class.new(root, output_dir: output_dir).build
    expect(cached.cached).to be(true)
    expect(cached.files_written).to eq(0)
  end

  it "lets the site override a theme layout" do
    root = copy_site!("demo")
    override_dir = File.join(root, "themes", "portfolio", "layouts")
    FileUtils.mkdir_p(override_dir)
    File.write(File.join(override_dir, "404.html.erb"),
               "<main><h1>custom not found marker</h1></main>")

    described_class.new(root, output_dir: output_dir, force: true).build
    expect(File.read(File.join(output_dir, "404.html"))).to include("custom not found marker")
  end

  it "escapes raw HTML from markdown by default" do
    root = copy_site!("demo")
    File.write(File.join(root, "content", "posts", "2026-11-12-inject.md"),
               "---\ntitle: Inject\ndate: 2026-11-12\n---\n<script>alert(1)</script>\n")

    described_class.new(root, output_dir: output_dir, force: true).build
    html = File.read(File.join(output_dir, "posts", "inject", "index.html"))
    expect(html).not_to include("<script>")
    expect(html).to include("&lt;script&gt;")
  end

  it "fails with a clear error on broken front matter" do
    root = copy_site!("demo")
    File.write(File.join(root, "content", "posts", "2026-11-12-broken.md"),
               "---\ntitle: [unclosed\n---\nBody\n")

    expect { described_class.new(root, output_dir: output_dir, force: true).build }
      .to raise_error(Quire::Error, /broken\.md/)
  end
end
