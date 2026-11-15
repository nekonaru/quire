# frozen_string_literal: true

RSpec.describe Quire::Markdown do
  it "renders headings and paragraphs" do
    html = described_class.render("# Title\n\nSome *text*.")
    expect(html).to include("<h1")
    expect(html).to include("<em>text</em>")
  end

  it "renders tables from GFM input" do
    html = described_class.render("| A | B |\n|---|---|\n| 1 | 2 |")
    expect(html).to include("<table>")
    expect(html).to include("<td>1</td>")
  end

  it "renders fenced code blocks with rouge highlighting" do
    html = described_class.render("```ruby\nputs 'hi'\n```")
    expect(html).to include("highlight")
    expect(html).to include("puts")
  end

  it "does not double-escape HTML inside indented code blocks" do
    html = described_class.render("para\n\n    <b>raw</b>\n")
    expect(html).to include("&lt;b&gt;")
    expect(html).not_to include("&amp;lt;")
  end

  it "renders double-backtick code spans containing angle brackets" do
    html = described_class.render("`` `<b>x</b>` ``")
    expect(html).to include("<code>")
    expect(html).to include("&lt;b&gt;x&lt;/b&gt;")
  end

  it "renders footnotes" do
    html = described_class.render("Text with a note[^1].\n\n[^1]: The note.")
    expect(html).to include("footnote")
  end

  it "escapes raw HTML by default" do
    html = described_class.render("<script>alert('x')</script>")
    expect(html).not_to include("<script>")
    expect(html).to include("&lt;script&gt;")
  end

  it "passes raw HTML through when allow_html is true" do
    html = described_class.render("<div class=\"note\">hi</div>", allow_html: true)
    expect(html).to include("<div class=\"note\">hi</div>")
  end

  it "does not escape HTML inside fenced code blocks" do
    html = described_class.render("```html\n<b>bold</b>\n```")
    expect(html).not_to include("<b>bold</b></code></pre>\n<pre><code")
    expect(html).to include("&lt;b&gt;")
  end

  it "keeps valid entity references readable" do
    html = described_class.render("Tom &amp; Jerry")
    expect(html).to include("Tom &amp; Jerry")
  end
end
