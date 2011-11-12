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
  s.description = %q{Provides an easy-to-use interface for making requests to the ChannelAdvisor API. Includes all methods for requesting and updating data via API version 5.}

  s.rubyforge_project = "channeladvisor"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "rb-notifu"
  s.add_runtime_dependency "savon"
end
