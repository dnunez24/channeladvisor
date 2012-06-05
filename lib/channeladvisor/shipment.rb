module ChannelAdvisor
  class Shipment
    attr_accessor :shipping_carrier, :shipping_class, :tracking_number

    def initialize(attrs={})
      unless attrs.nil?
        @shipping_carrier = attrs[:shipping_carrier]
        @shipping_class   = attrs[:shipping_class]
        @tracking_number  = attrs[:tracking_number]
      end
    end
  end
end