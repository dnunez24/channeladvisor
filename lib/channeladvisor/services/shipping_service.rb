module ChannelAdvisor
  module Services
    class ShippingService < BaseService
      document "https://api.channeladvisor.com/ChannelAdvisorAPI/v6/ShippingService.asmx?WSDL"

      class << self
        # Check authorization for and availability of the shipping service
        #
        # @return [Savon::SOAP::Response] SOAP XML response object
        def ping
          client.request :ping do
            soap.header = soap_header
          end
        end

        # Submit a list of order shipments (full or partial)
        #
        # @param [Hash, Array<Hash>] shipment_data One or more shipment hashes
        #
        # @return [Savon::SOAP::Response] SOAP XML response object
        #
        # @example Submit a partial shipment
        #   partial_shipment = {
        #     :order_id => 123456,
        #     :client_order_id => "ABCD1234",
        #     :type => "Partial",
        #     :line_items => [{:sku => "ABCD", :quantity => 5}],
        #     :date => DateTime.new(2012,05,19),
        #     :carrier => "UPS",
        #     :class => "GND",
        #     :tracking_number => "1ZABCD2134567890",
        #     :seller_id => "999999",
        #     :cost => 7.50,
        #     :tax => 1.50,
        #     :insurance => 2.50
        #   }
        #
        #   ShippingService.submit_order_shipment_list(partial_shipment)
        #
        # @example Submit a full shipment
        #   full_shipment = {
        #     :order_id => 123456,
        #     :client_order_id => "ABCD1234",
        #     :type => "Full",
        #     :date => DateTime.new(2012,05,19),
        #     :carrier => "UPS",
        #     :class => "GND",
        #     :tracking_number => "1ZABCD2134567890",
        #     :seller_id => "999999",
        #     :cost => 7.50,
        #     :tax => 1.50,
        #     :insurance => 2.50
        #   }
        #
        #   ShippingService.submit_order_shipment_list(full_shipment)
        #
        # @example Submit multiple shipments
        #   partial_shipment = {
        #     :order_id => 123456,
        #     :client_order_id => "ABCD1234",
        #     :type => "Partial",
        #     :line_items => [{:sku => "ABCD", :quantity => 5}],
        #     :date => DateTime.new(2012,05,19),
        #     :carrier => "UPS",
        #     :class => "GND",
        #     :tracking_number => "1ZABCD2134567890",
        #     :seller_id => "999999",
        #     :cost => 7.50,
        #     :tax => 1.50,
        #     :insurance => 2.50
        #   }
        #
        #   full_shipment = {
        #     :order_id => 123456,
        #     :client_order_id => "ABCD1234",
        #     :type => "Full",
        #     :date => DateTime.new(2012,05,19),
        #     :carrier => "UPS",
        #     :class => "GND",
        #     :tracking_number => "1ZABCD2134567890",
        #     :seller_id => "999999",
        #     :cost => 7.50,
        #     :tax => 1.50,
        #     :insurance => 2.50
        #   }
        #
        #   shipments = []
        #   shipments << partial_shipment
        #   shipments << full_shipment
        #
        #   ShippingService.submit_order_shipment_list(shipments)
        def submit_order_shipment_list(shipment_data)
          shipments = shipment_data.map { |shipment| build_shipment(shipment) }
          order_shipment = shipments.count > 1 ? shipments : shipments.first

          client.request :submit_order_shipment_list do
            soap.header = soap_header
            soap.body = {
              "ins0:accountID" => creds(:account_id),
              "ins0:ShipmentList" => {
                "ins0:ShipmentList" => {
                  "ins0:OrderShipment" => order_shipment
                }
              }
            }
          end
        end

        def get_shipping_carrier_list
          client.request :get_shipping_carrier_list do
            soap.header = soap_header
            soap.body = {"ins0:accountID" => creds(:account_id)}
          end
        end

      private

        def build_shipment(shipment)
          order_shipment = {}
          order_shipment["ins0:OrderId"]                = shipment[:order_id]
          order_shipment["ins0:ClientOrderIdentifier"]  = shipment[:client_order_id] if shipment[:client_order_id]
          order_shipment["ins0:ShipmentType"]           = shipment[:type]

          if shipment[:type] == "Partial"
            partial_shipment = order_shipment["ins0:PartialShipment"] = {
              "ins0:shipmentContents" => {
                "ins0:LineItemList" => {
                  "ins0:LineItem" => []
                }
              }
            }

            line_items = partial_shipment["ins0:shipmentContents"]["ins0:LineItemList"]["ins0:LineItem"]

            shipment[:line_items].each do |item|
              line_items << {"ins0:SKU" => item[:sku], "ins0:Quantity" => item[:quantity]}
            end

            partial_shipment["ins0:dateShippedGMT"]       = shipment[:date]
            partial_shipment["ins0:carrierCode"]          = shipment[:carrier]         if shipment[:carrier]
            partial_shipment["ins0:classCode"]            = shipment[:class]           if shipment[:class]
            partial_shipment["ins0:trackingNumber"]       = shipment[:tracking_number] if shipment[:tracking_number]
            partial_shipment["ins0:sellerFulfillmentID"]  = shipment[:seller_id]       if shipment[:seller_id]
            partial_shipment["ins0:shipmentCost"]         = shipment[:cost]
            partial_shipment["ins0:shipmentTaxCost"]      = shipment[:tax]
            partial_shipment["ins0:insuranceCost"]        = shipment[:insurance]
          else
            full_shipment = order_shipment["ins0:FullShipment"] = {}
            full_shipment["ins0:dateShippedGMT"]          = shipment[:date]
            full_shipment["ins0:carrierCode"]             = shipment[:carrier]         if shipment[:carrier]
            full_shipment["ins0:classCode"]               = shipment[:class]           if shipment[:class]
            full_shipment["ins0:trackingNumber"]          = shipment[:tracking_number] if shipment[:tracking_number]
            full_shipment["ins0:sellerFulfillmentID"]     = shipment[:seller_id]       if shipment[:seller_id]
            full_shipment["ins0:shipmentCost"]            = shipment[:cost]
            full_shipment["ins0:shipmentTaxCost"]         = shipment[:tax]
            full_shipment["ins0:insuranceCost"]           = shipment[:insurance]
          end

          return order_shipment
        end # build_shipment
      end # self
    end # ShippingService
  end # Services
end # ChannelAdvisor