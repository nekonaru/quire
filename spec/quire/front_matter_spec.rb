# frozen_string_literal: true

RSpec.describe Quire::FrontMatter do
  it "handles a UTF-8 byte order mark" do
    text = "\uFEFF---\ntitle: Hello\n---\nBody\n"
    attributes, = described_class.parse(text, file: "test.md")
    expect(attributes["title"]).to eq("Hello")
  end

  it "returns empty attributes for content without front matter" do
    attributes, body, _line = described_class.parse("just text\n", file: "test.md")
    expect(attributes).to eq({})
    expect(body).to eq("just text\n")
  end

  it "parses YAML front matter" do
    text = "---\ntitle: Hello\ntags:\n  - ruby\n---\nBody\n"
    attributes, body, = described_class.parse(text, file: "test.md")
    expect(attributes["title"]).to eq("Hello")
    expect(attributes["tags"]).to eq(["ruby"])
    expect(body).to eq("Body\n")
  end

  it "parses date values as Date objects" do
    text = "---\ndate: 2026-11-15\n---\nBody\n"
    attributes, = described_class.parse(text, file: "test.md")
    expect(attributes["date"]).to eq(Date.new(2026, 11, 15))
  end

  it "raises with file reference when closing marker is missing" do
    expect { described_class.parse("---\ntitle: Hello\n", file: "test.md") }
      .to raise_error(Quire::Error, /test\.md.*no closing/i)
  end

  it "raises with file and line on invalid YAML" do
    expect { described_class.parse("---\ntitle: [unclosed\n---\nBody\n", file: "test.md") }
      .to raise_error(Quire::Error, /test\.md.*invalid YAML/i)
  end

  it "rejects non-mapping front matter" do
    expect { described_class.parse("---\n- just\n- a\n- list\n---\nBody\n", file: "test.md") }
      .to raise_error(Quire::Error, /must be a YAML mapping/)
  end

  it "rejects YAML aliases" do
    expect { described_class.parse("---\na: &x 1\nb: *x\n---\nBody\n", file: "test.md") }
      .to raise_error(Quire::Error)
  end
end
