# frozen_string_literal: true

RSpec.describe Quire::StaticSite do
  let(:public_dir) { Dir.mktmpdir("quire-public") }
  let(:site) { described_class.new(public_dir) }

  after { FileUtils.remove_entry(public_dir) }

  def write(relative, content)
    path = File.join(public_dir, relative)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  it "serves index.html for directory URLs" do
    write("index.html", "<h1>home</h1>")
    status, type, body, = site.handle("/")
    expect(status).to eq(200)
    expect(type).to eq("text/html")
    expect(body).to include("<h1>home</h1>")
  end

  it "serves a pretty URL and redirects the non-trailing-slash form" do
    write("about/index.html", "<h1>about</h1>")
    status, = site.handle("/about")
    expect(status).to eq(301)

    status, _type, body, = site.handle("/about/")
    expect(status).to eq(200)
    expect(body).to include("<h1>about</h1>")
  end

  it "serves 404.html with status 404 for missing paths" do
    write("404.html", "<h1>missing</h1>")
    status, _type, body, = site.handle("/nope/")
    expect(status).to eq(404)
    expect(body).to include("<h1>missing</h1>")
  end

  it "refuses path traversal outside the public directory" do
    write("secret.html", "hidden")
    secret = File.expand_path("../secret.txt", public_dir)
    File.write(secret, "outside")
    status, = site.handle("/../secret.txt")
    expect(status).to eq(404)
  end

  it "injects the live reload script into HTML responses only" do
    write("index.html", "<html><body><p>hi</p></body></html>")
    write("style.css", "body { color: red; }")

    _status, _type, html, = site.handle("/")
    _status, _type, css, = site.handle("/style.css")
    expect(html).to include("/__quire/version")
    expect(css).not_to include("/__quire/version")
  end
end
