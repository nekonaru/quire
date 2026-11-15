# frozen_string_literal: true

require "quire"
require "tmpdir"
require "fileutils"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  # Copy an example/site fixture into a fresh tmp directory so tests never
  # write into the repository.
  def copy_site!(name)
    source = File.expand_path("../examples/#{name}", __dir__)
    dir = Dir.mktmpdir("quire-#{name}")
    FileUtils.cp_r(Dir[File.join(source, ".")], dir)
    dir
  end
end
