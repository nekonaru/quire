# frozen_string_literal: true

require "rexml/document"

RSpec.describe Quire::Feed do
  let(:site) { instance_double("Quire::Site", config: config) }
  let(:config) do
    instance_double("Quire::Config",
                    title: "Example Site",
                    description: "Example description",
                    author: "Nicolas Dwi Dharma",
                    base_url: "https://example.com")
  end

  let(:post) do
    instance_double("Quire::Document",
                    title: "Hello",
                    url: "/posts/hello/",
                    date: Date.new(2026, 11, 1),
                    description: "",
                    excerpt: "An excerpt")
  end

  it "builds a valid Atom feed" do
    xml = described_class.new(site).to_xml([post])
    document = REXML::Document.new(xml)
    expect(document.root.name).to eq("feed")
    expect(REXML::XPath.first(document, "//title").text).to eq("Example Site")
    expect(REXML::XPath.match(document, "//entry/title").map(&:text)).to include("Hello")
    expect(REXML::XPath.first(document, "//entry/link").attributes["href"]).to eq("https://example.com/posts/hello/")
  end

  it "escapes HTML in titles" do
    allow(post).to receive(:title).and_return("<b>Hi</b>")
    xml = described_class.new(site).to_xml([post])
    expect(xml).to include("&lt;b&gt;Hi&lt;/b&gt;")
    expect(xml).not_to include("<b>Hi</b>")
  end

  it "handles an empty post list" do
    xml = described_class.new(site).to_xml([])
    expect(xml).to include("<feed")
    expect(xml).not_to include("<entry>")
  end
end
