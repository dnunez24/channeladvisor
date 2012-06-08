$:.unshift File.expand_path("../lib", __FILE__)
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "channeladvisor/version"

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["--format progress"]
end

task :default => :spec
 
task :build do
  system "gem build channeladvisor.gemspec"
end
 
task :release => :build do
  system "gem push channeladvisor-#{ChannelAdvisor::VERSION}"
end

desc "Display current gem version"
task :version do
  puts "Current version: #{ChannelAdvisor::VERSION}"
end

namespace :version do
  desc "Bump version (defaults to patch)"
  task :bump => "bump:patch"

  namespace :bump do
    desc "Bump major version"
    task :major => :version do |t|
      bump_version(t.name.split(":").last)
    end

    desc "Bump minor version"
    task :minor => :version do |t|
      bump_version(t.name.split(":").last)
    end

    desc "Bump patch version"
    task :patch => :version do |t|
      bump_version(t.name.split(":").last)
    end
  end
end

def bump_version(segment)
  segments = ChannelAdvisor::VERSION.split(".").map(&:to_i)

  case segment
  when "major"
    segments[0] = segments[0] + 1 
    segments[1] = 0
    segments[2] = 0
  when "minor"
    segments[1] = segments[1] + 1 
    segments[2] = 0
  when "patch"
    segments[2] = segments[2] + 1 
  end

  new_version = segments.join(".")

  file_name = "lib/channeladvisor/version.rb"
  new_text = File.read(file_name).gsub(ChannelAdvisor::VERSION, new_version)
  File.open(file_name, "w") { |f| f.puts new_text }

  puts "New version: #{new_version}" 
end