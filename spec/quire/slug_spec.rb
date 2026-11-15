# frozen_string_literal: true

RSpec.describe Quire::Slug do
  it "slugifies basic titles" do
    expect(Quire::Slug.slugify("Hello World")).to eq("hello-world")
  end

  it "strips punctuation and collapses separators" do
    expect(Quire::Slug.slugify("  Rock & Roll! Again... ")).to eq("rock-roll-again")
  end

  it "removes diacritics" do
    expect(Quire::Slug.slugify("Crème brûlée à la mode")).to eq("creme-brulee-a-la-mode")
  end

  it "handles CJK by dropping non-ASCII output" do
    expect(Quire::Slug.slugify("日本語 テスト")).to eq("")
  end

  it "returns empty string for unusable input" do
    expect(Quire::Slug.slugify("!!!")).to eq("")
  end
end
