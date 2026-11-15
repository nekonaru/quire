# frozen_string_literal: true

require "rake"

desc "Run tests and rubocop"
task default: %w[spec rubocop]

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  desc "Run tests (rspec not installed)"
  task :spec do
    abort "rspec is not available; run bundle install first"
  end
end

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:rubocop)
rescue LoadError
  desc "Run rubocop (not installed)"
  task :rubocop do
    abort "rubocop is not available; run bundle install first"
  end
end
