# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "channeladvisor/version"

Gem::Specification.new do |s|
  s.name        = "channeladvisor"
  s.version     = ChannelAdvisor::VERSION
  s.authors     = ["Dave Nunez"]
  s.email       = ["dnunez24@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Ruby wrapper for the ChannelAdvisor API}
  s.description = %q{Provides an easy-to-use interface for making requests to the ChannelAdvisor API. Includes all methods for requesting and updating data via API version 6.}

  s.required_ruby_version = ">= 1.9.2"
  s.rubyforge_project = "channeladvisor"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2.0"
  s.add_development_dependency "rr", "~> 1.0.0"
  s.add_development_dependency "vcr", "~> 2.2.0"
  s.add_development_dependency "fakeweb", "~> 1.3.0"
  s.add_development_dependency "timecop"

  s.add_runtime_dependency "savon", "~> 1.0.0"
end
