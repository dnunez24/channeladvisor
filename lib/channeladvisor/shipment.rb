module ChannelAdvisor
  class Shipment < Base
    attr_accessor :shipping_carrier, :shipping_class, :tracking_number

    def initialize(attrs={})
      @shipping_carrier = attrs[:shipping_carrier]
      @shipping_class   = attrs[:shipping_class]
      @tracking_number  = attrs[:tracking_number]
    end

    def self.submit(shipment_data)
      handle_errors do
        shipments = arrayify(shipment_data)

        shipments.each do |shipment|
          shipment[:type] = shipment[:line_items] ? "Partial" : "Full"
          shipment[:date] ||= DateTime.now
          shipment[:cost]       = "%.2f" % shipment[:cost].to_f
          shipment[:tax]        = "%.2f" % shipment[:tax].to_f
          shipment[:insurance]  = "%.2f" % shipment[:insurance].to_f
        end

        response = Services::ShippingService.submit_order_shipment_list(shipments)
        result = response[:submit_order_shipment_list_response][:submit_order_shipment_list_result]
        check_status_of result

        shipment_responses = arrayify result[:result_data][:shipment_response]

        if shipment_responses.count == 1
          return shipment_responses.first[:success]
        else
          result_hash = {}
          shipment_responses.each do |shipment_response|
            shipments.each do |shipment|
              result_hash[shipment[:order_id].to_s] = shipment_response[:success]
            end
          end
          return result_hash
        end

        # if bools.is_a? Array
        #   result_hash = {}

        #   bools.each do |bool|
        #     shipments.each do |shipment|
        #       result_hash[shipment[:order_id]] = bool
        #     end
        #   end

        #   return result_hash
        # else
        #   return bools
        # end

      end
    end
  end
end