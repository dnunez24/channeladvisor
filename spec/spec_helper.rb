require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
end

require 'channeladvisor'
require 'fakeweb'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rr
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

Savon.config.log = false
ChannelAdvisor::Services::AdminService.client.config.log = false
ChannelAdvisor::Services::OrderService.client.config.log = false
ChannelAdvisor::Services::ShippingService.client.config.log = false
ChannelAdvisor::Services::InventoryService.client.config.log = false

HTTPI.log = false
