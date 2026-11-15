# frozen_string_literal: true

RSpec.describe Quire::Config do
  let(:dir) { Dir.mktmpdir("quire-config") }

  after { FileUtils.remove_entry(dir) }

  it "raises a clear error when quire.yml is missing" do
    expect { described_class.new(dir) }.to raise_error(Quire::Error, /missing quire\.yml/)
  end

  it "applies defaults on top of an empty file" do
    File.write(File.join(dir, "quire.yml"), "")
    config = described_class.new(dir)
    expect(config.title).to eq("Quire Site")
    expect(config.theme).to eq("blog")
    expect(config.posts_per_page).to eq(10)
    expect(config.base_url).to eq("")
  end

  it "strips trailing slashes from base_url" do
    File.write(File.join(dir, "quire.yml"), "base_url: https://example.com/site/\n")
    expect(described_class.new(dir).base_url).to eq("https://example.com/site")
  end

  it "builds absolute urls" do
    File.write(File.join(dir, "quire.yml"), "base_url: https://example.com\n")
    expect(described_class.new(dir).absolute_url("/posts/x/")).to eq("https://example.com/posts/x/")
  end

  it "rejects a non-integer posts_per_page" do
    File.write(File.join(dir, "quire.yml"), "posts_per_page: lots\n")
    expect { described_class.new(dir) }.to raise_error(Quire::Error, /posts_per_page/)
  end

  it "rejects menu entries without title or url" do
    File.write(File.join(dir, "quire.yml"), "menu:\n  - title: About\n")
    expect { described_class.new(dir) }.to raise_error(Quire::Error, /menu/)
  end
end
