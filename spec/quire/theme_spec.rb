# frozen_string_literal: true

RSpec.describe Quire::Theme do
  let(:site_root) { Dir.mktmpdir("quire-theme") }

  after { FileUtils.remove_entry(site_root) }

  it "loads a built-in theme" do
    theme = described_class.load("blog", site_root)
    expect(File.basename(theme.layout_path("post"))).to eq("post.html.erb")
  end

  it "raises for unknown themes" do
    expect { described_class.load("nope", site_root) }.to raise_error(Quire::Error, /unknown theme/)
  end

  it "lets the site override a single layout file" do
    override_dir = File.join(site_root, "themes", "blog", "layouts")
    FileUtils.mkdir_p(override_dir)
    override = File.join(override_dir, "post.html.erb")
    File.write(override, "<article>overridden</article>")

    theme = described_class.load("blog", site_root)
    expect(theme.layout_path("post")).to eq(override)
  end

  it "falls back to the built-in file when the site overrides another one" do
    theme = described_class.load("portfolio", site_root)
    expect(File.read(theme.layout_path("index"))).to include("project-grid")
  end

  it "lists site and built-in asset roots with the site first" do
    asset_dir = File.join(site_root, "themes", "blog", "assets")
    FileUtils.mkdir_p(asset_dir)

    theme = described_class.load("blog", site_root)
    expect(theme.asset_dirs.first).to eq(asset_dir)
    expect(theme.asset_dirs.length).to eq(2)
  end
end
