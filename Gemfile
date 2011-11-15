source "http://rubygems.org"

# Specify your gem's dependencies in channeladvisor.gemspec
gemspec

group :test do
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'guard-yard',   :platforms => [:ruby]
  gem 'rb-inotify',   :require => false if RUBY_PLATFORM =~ /linux/i
  gem 'libnotify',    :require => false if RUBY_PLATFORM =~ /linux/i
  gem 'rb-fsevent',   :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'growl',        :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'win32console', :require => false, :platforms => [:mswin, :mingw]
  gem 'rb-fchange',   :require => false, :platforms => [:mswin, :mingw]
  gem 'rb-notifu',    :require => false, :platforms => [:mswin, :mingw]
end

group :development do
  gem 'yard'
  gem 'redcarpet'
end