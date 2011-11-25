require 'savon'
require 'channeladvisor/version'
require 'channeladvisor/error'
require 'channeladvisor/configuration'
require 'channeladvisor/connection'
require 'channeladvisor/order'

module ChannelAdvisor
	extend Configuration

	def self.configure(&block)
		yield self if block_given?
	end
end
