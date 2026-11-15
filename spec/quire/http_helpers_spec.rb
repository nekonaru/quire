# frozen_string_literal: true

RSpec.describe Quire::HttpHelpers do
  describe ".local_host?" do
    it "accepts loopback hosts with and without ports" do
      expect(described_class.local_host?("127.0.0.1")).to be(true)
      expect(described_class.local_host?("127.0.0.1:4000")).to be(true)
      expect(described_class.local_host?("localhost")).to be(true)
      expect(described_class.local_host?("localhost:4000")).to be(true)
      expect(described_class.local_host?("[::1]:4000")).to be(true)
    end

    it "rejects anything else" do
      expect(described_class.local_host?("example.com")).to be(false)
      expect(described_class.local_host?("0.0.0.0")).to be(false)
      expect(described_class.local_host?("192.168.1.10:4000")).to be(false)
      expect(described_class.local_host?("")).to be(false)
      expect(described_class.local_host?(nil)).to be(false)
    end
  end

  describe ".safe_within?" do
    it "confines paths to the base directory" do
      expect(described_class.safe_within?("/site/public", "/site/public/posts/x/index.html")).to be(true)
      expect(described_class.safe_within?("/site/public", "/site/public/../secret")).to be(false)
      expect(described_class.safe_within?("/site/public", "/site/other")).to be(false)
    end
  end
end
