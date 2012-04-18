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
  config.include StubWsdlAndResponse

  config.before(:each) do
    FakeWeb.clean_registry
  end
end

Savon.configure do |config|
	config.log = false
end

HTTPI.log = false

FakeWeb.allow_net_connect = false
