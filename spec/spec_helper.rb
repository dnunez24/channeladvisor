require 'rubygems'
require 'bundler/setup'

begin
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
rescue => LoadError
  # not able to load 'simplecov' do nothing
end

require 'channeladvisor'
require 'fakeweb'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

Savon.configure do |config|
	config.log = false
end

HTTPI.log = false
