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
  index = case segment
  when "major"
    0
  when "minor"
    1
  when "patch"
    2
  end

  segments = ChannelAdvisor::VERSION.split(".").map(&:to_i)
  segments[index] = segments[index] + 1 
  new_version = segments.join(".")

  file_name = "lib/channeladvisor/version.rb"
  new_text = File.read(file_name).gsub(ChannelAdvisor::VERSION, new_version)
  File.open(file_name, "w") { |f| f.puts new_text }

  puts "New version: #{new_version}" 
end