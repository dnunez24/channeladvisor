module ChannelAdvisor
  module Services
    class ShippingService < BaseService
      document "https://api.channeladvisor.com/ChannelAdvisorAPI/v6/ShippingService.asmx?WSDL"

      class << self
        def ping
          soap_response = client.request :ping do
            soap.header = soap_header
          end

          @last_request = client.http
          @last_response = soap_response
        end

        def submit_order_shipment_list(shipments)
          order_shipments = []

          shipments.each do |shipment|
            order_shipment = {}
            order_shipment["ins0:OrderId"]                = shipment[:order_id]
            order_shipment["ins0:ClientOrderIdentifier"]  = shipment[:client_order_id] if shipment[:client_order_id]

            if shipment[:line_items]
              order_shipment["ins0:ShipmentType"] = "Partial"
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

              partial_shipment["ins0:dateShippedGMT"]       = shipment[:date] || DateTime.now
              partial_shipment["ins0:carrierCode"]          = shipment[:carrier]         if shipment[:carrier]
              partial_shipment["ins0:classCode"]            = shipment[:class]           if shipment[:class]
              partial_shipment["ins0:trackingNumber"]       = shipment[:tracking_number] if shipment[:tracking_number]
              partial_shipment["ins0:sellerFulfillmentID"]  = shipment[:seller_id]       if shipment[:seller_id]
              partial_shipment["ins0:shipmentCost"]         = "%.2f" % shipment[:cost]
              partial_shipment["ins0:shipmentTaxCost"]      = "%.2f" % shipment[:tax]
              partial_shipment["ins0:insuranceCost"]        = "%.2f" % shipment[:insurance]
            else
              order_shipment["ins0:ShipmentType"]           = "Full"
              full_shipment = order_shipment["ins0:FullShipment"] = {}
              full_shipment["ins0:dateShippedGMT"]          = shipment[:date] || DateTime.now
              full_shipment["ins0:carrierCode"]             = shipment[:carrier]         if shipment[:carrier]
              full_shipment["ins0:classCode"]               = shipment[:class]           if shipment[:class]
              full_shipment["ins0:trackingNumber"]          = shipment[:tracking_number] if shipment[:tracking_number]
              full_shipment["ins0:sellerFulfillmentID"]     = shipment[:seller_id]       if shipment[:seller_id]
              full_shipment["ins0:shipmentCost"]            = "%.2f" % shipment[:cost]
              full_shipment["ins0:shipmentTaxCost"]         = "%.2f" % shipment[:tax]
              full_shipment["ins0:insuranceCost"]           = "%.2f" % shipment[:insurance]
            end
            order_shipments << order_shipment
          end

          client.request :submit_order_shipment_list do
            soap.header = soap_header
            soap.body = {
              "ins0:accountID" => creds(:account_id),
              "ins0:ShipmentList" => {
                "ins0:ShipmentList" => {
                  "ins0:OrderShipment" => (order_shipments.count > 1 ? order_shipments : order_shipments.first)
                }
              }
            }
          end
        end
      end
    end
  end
end