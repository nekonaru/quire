# frozen_string_literal: true

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
    expect(xml).to include("<feed xmlns=\"http://www.w3.org/2005/Atom\">")
    expect(xml).to include("<title>Hello</title>")
    expect(xml).to include("https://example.com/posts/hello/")
    expect(xml).to include("An excerpt")
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
