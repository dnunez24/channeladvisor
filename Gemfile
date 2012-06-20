source "http://rubygems.org"

# Specify your gem's dependencies in channeladvisor.gemspec
gemspec

gem 'yard'
gem 'redcarpet'
gem 'guard-rspec', '~> 1.1.0'
gem 'guard-bundler', '~> 1.0.0'
gem 'guard-yard', '~> 2.0.0', :platforms => [:ruby] if RUBY_VERSION >= '1.9.2'
gem 'rb-inotify',   :require => false if RUBY_PLATFORM =~ /linux/i
gem 'libnotify',    :require => false if RUBY_PLATFORM =~ /linux/i
gem 'rb-fsevent',   :require => false if RUBY_PLATFORM =~ /darwin/i
gem 'growl',        :require => false if RUBY_PLATFORM =~ /darwin/i
gem 'win32console', :require => false, :platforms => [:mswin, :mingw]
gem 'rb-fchange',   :require => false, :platforms => [:mswin, :mingw]
gem 'rb-notifu',    :require => false, :platforms => [:mswin, :mingw]

platform :ruby_19 do
  gem 'simplecov'
end


# platform :ruby_19 do
#   gem 'ruby-debug19'
#   gem 'pry'
# end
