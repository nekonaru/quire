# frozen_string_literal: true

RSpec.describe Quire::Paginator do
  it "computes total pages" do
    expect(described_class.new(21, 5).total_pages).to eq(5)
    expect(described_class.new(20, 5).total_pages).to eq(4)
    expect(described_class.new(0, 5).total_pages).to eq(1)
  end

  it "slices items for a page" do
    items = (1..12).to_a
    pager = described_class.new(12, 5, 2)
    expect(pager.slice(items)).to eq([6, 7, 8, 9, 10])
  end

  it "marks first and last pages" do
    first = described_class.new(12, 5, 1)
    last = described_class.new(12, 5, 3)
    expect(first.first?).to be(true)
    expect(first.prev_url).to be_nil
    expect(last.last?).to be(true)
    expect(last.next_url).to be_nil
  end

  it "builds URLs for page numbers" do
    expect(described_class.url_for(1)).to eq("/")
    expect(described_class.url_for(3)).to eq("/page/3/")
  end

  it "lists all page urls" do
    expect(described_class.new(12, 5).page_urls).to eq(["/", "/page/2/", "/page/3/"])
  end
end
