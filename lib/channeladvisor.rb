require 'channeladvisor/version'
require 'channeladvisor/configuration'
require 'channeladvisor/connection'
require 'channeladvisor/order'
require 'savon'

module ChannelAdvisor
	extend Configuration

	def self.configure(&block)
		yield self if block_given?
	end

	class ServiceFailure < StandardError; end
end
