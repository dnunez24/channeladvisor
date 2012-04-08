require 'savon'
require 'channeladvisor/version'
require 'channeladvisor/error'
require 'channeladvisor/configuration'
require 'channeladvisor/client'
require 'channeladvisor/order'

module ChannelAdvisor
	def self.configuration
		@configuration ||= Configuration.new
	end

	def self.configure
		yield configuration if block_given?
	end
end
