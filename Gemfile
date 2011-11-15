source "http://rubygems.org"

# Specify your gem's dependencies in channeladvisor.gemspec
gemspec

platforms :mswin do
  gem 'win32console'
  gem 'rb-fchange'
  gem 'rb-notifu'
end

platforms :ruby do
  gem 'rb-inotify'    if RUBY_PLATFORM =~ /linux/i
  gem 'libnotify'     if RUBY_PLATFORM =~ /linux/i
  gem 'rb-fsevent'    if RUBY_PLATFORM =~ /darwin/i
  gem 'growl'         if RUBY_PLATFORM =~ /darwin/i
end

group :test do
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'guard-yard'
end

group :development do
  gem 'yard'
  gem 'redcarpet'
end