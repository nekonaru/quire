# frozen_string_literal: true

RSpec.describe Quire::Sitemap do
  it "builds a urlset with absolute URLs" do
    xml = described_class.new("https://example.com/").to_xml(["/", "/posts/x/"])
    expect(xml).to include("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">")
    expect(xml).to include("<loc>https://example.com/</loc>")
    expect(xml).to include("<loc>https://example.com/posts/x/</loc>")
  end

  it "deduplicates urls" do
    xml = described_class.new("https://example.com").to_xml(["/", "/"])
    expect(xml.scan("<url>").length).to eq(1)
  end

  it "escapes URLs" do
    xml = described_class.new("https://example.com").to_xml(["/a&b/"])
    expect(xml).to include("/a&amp;b/")
  end
end
