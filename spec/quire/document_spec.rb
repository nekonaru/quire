# frozen_string_literal: true

RSpec.describe Quire::Document do
  let(:dir) { Dir.mktmpdir("quire-doc") }

  after { FileUtils.remove_entry(dir) }

  def write_post(name, content)
    path = File.join(dir, name)
    File.write(path, content)
    path
  end

  it "derives date and slug from a YYYY-MM-DD filename prefix" do
    path = write_post("2026-05-04-hello-world.md", "---\ntitle: Hello\n---\nBody\n")
    doc = described_class.new(path, kind: :post)
    expect(doc.date).to eq(Date.new(2026, 5, 4))
    expect(doc.slug).to eq("hello-world")
    expect(doc.url).to eq("/posts/hello-world/")
  end

  it "lets front matter win over the filename" do
    path = write_post("2026-05-04-hello-world.md", "---\ntitle: Hello\ndate: 2020-01-01\nslug: custom\n---\nBody\n")
    doc = described_class.new(path, kind: :post)
    expect(doc.date).to eq(Date.new(2020, 1, 1))
    expect(doc.slug).to eq("custom")
  end

  it "defaults title to the file name" do
    path = write_post("about.md", "---\nlayout: page\n---\nBody\n")
    doc = described_class.new(path, kind: :page)
    expect(doc.title).to eq("about")
    expect(doc.layout).to eq("page")
  end

  it "treats draft strings as truthy" do
    path = write_post("x.md", "---\ndraft: true\n---\nBody\n")
    expect(described_class.new(path, kind: :post).draft?).to be(true)
  end

  it "excerpt strips markdown syntax and truncates" do
    path = write_post("x.md", "---\ntitle: X\n---\nSome **bold** text with [a link](https://example.com) in it.\n")
    excerpt = described_class.new(path, kind: :post).excerpt
    expect(excerpt).to include("Some bold text")
    expect(excerpt).not_to include("**")
  end
end
