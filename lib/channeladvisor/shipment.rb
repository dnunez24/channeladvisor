module ChannelAdvisor
  class Shipment < Base
    attr_accessor :shipping_carrier, :shipping_class, :tracking_number

    def initialize(attrs={})
      @shipping_carrier = attrs[:shipping_carrier]
      @shipping_class   = attrs[:shipping_class]
      @tracking_number  = attrs[:tracking_number]
    end

    def self.submit(shipment_data)
      shipments = arrayify(shipment_data).each do |shipment|
        shipment[:type] = shipment[:line_items] ? "Partial" : "Full"
        shipment[:date] ||= DateTime.now
        shipment[:cost]       = "%.2f" % shipment[:cost].to_f
        shipment[:tax]        = "%.2f" % shipment[:tax].to_f
        shipment[:insurance]  = "%.2f" % shipment[:insurance].to_f
      end
      Services::ShippingService.submit_order_shipment_list(shipments)
    end
  end
end