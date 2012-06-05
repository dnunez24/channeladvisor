module ChannelAdvisor
  class OrderStatus
    attr_accessor :checkout, :payment, :shipping, :refund

    def initialize(attrs={})
      unless attrs.nil?
        @checkout = [attrs[:checkout_status], attrs[:checkout_date_gmt]]
        @payment  = [attrs[:payment], attrs[:payment_date_gmt]]
        @shipping = [attrs[:shipping], attrs[:shipping_date_gmt]]
        @refund   = attrs[:order_refund_status]
      end
    end
  end
end