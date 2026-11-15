# frozen_string_literal: true

require "yaml"

RSpec.describe Quire::CLI do
  let(:dir) { Dir.mktmpdir("quire-cli") }

  after { FileUtils.remove_entry(dir) }

  def new_post(title)
    described_class.start(["new", "post", title, "--path", dir])
  end

  it "creates a post with round-trippable front matter" do
    new_post("My: Post")
    file = Dir[File.join(dir, "content", "posts", "*.md")].first
    content = File.read(file)
    attributes = YAML.safe_load(content.split(/^---\s*$/)[1])
    expect(attributes["title"]).to eq("My: Post")
    expect(attributes["draft"]).to be(false)
  end

  it "escapes a title with a newline instead of injecting keys" do
    new_post("Evil\ndraft: true")
    file = Dir[File.join(dir, "content", "posts", "*.md")].first
    attributes = YAML.safe_load(File.read(file).split(/^---\s*$/)[1])
    expect(attributes["title"]).to eq("Evil\ndraft: true")
    expect(attributes["draft"]).to be(false)
  end

  it "rejects extra arguments for new site" do
    expect { described_class.start(["new", "site", "my", "cool", "site", "--path", dir]) }
      .to raise_error(SystemExit)
  end
end
