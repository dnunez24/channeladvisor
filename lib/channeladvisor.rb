require 'savon'
require 'channeladvisor/version'
require 'channeladvisor/error'
require 'channeladvisor/configuration'
require 'channeladvisor/client'
require 'channeladvisor/services'
require 'channeladvisor/base'
require 'channeladvisor/admin'
require 'channeladvisor/order'
require 'channeladvisor/order_status'
require 'channeladvisor/payment'
require 'channeladvisor/shipment'
require 'channeladvisor/address'
require 'channeladvisor/shopping_cart'
require 'channeladvisor/line_item'
require 'channeladvisor/account_authorization'

module ChannelAdvisor
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end
end

