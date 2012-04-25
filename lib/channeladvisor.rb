require 'savon'
require 'channeladvisor/version'
require 'channeladvisor/error'
require 'channeladvisor/configuration'
require 'channeladvisor/client'
require 'channeladvisor/services'
require 'channeladvisor/base'
require 'channeladvisor/order'
require 'channeladvisor/admin'

module ChannelAdvisor
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration if block_given?
    end
  end
end
