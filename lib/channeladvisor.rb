require 'channeladvisor/version'
require 'channeladvisor/configuration'
require 'channeladvisor/connection'

module ChannelAdvisor
	extend Configuration

	def self.configure(&block)
		yield self if block_given?
	end
end
