require 'rubygems'
require 'bundler/setup'
require 'channeladvisor'
require 'fakeweb'

Savon.configure do |config|
	config.log = false
end

HTTPI.log = false