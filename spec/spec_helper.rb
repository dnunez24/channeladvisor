require 'rubygems'
require 'bundler/setup'
require 'channeladvisor'
require 'fakeweb'

ChannelAdvisor.configure do |config|
	config.account_id = "3c2e240d-e754-48a7-a629-6b29dd1ea7fc"
	config.developer_key = "fc180712-adb1-49b6-8553-793c2de055a8"
	config.password = "M@s0chist"
end
