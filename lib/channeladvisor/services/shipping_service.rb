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

        def submit_order_shipment_list(shipments={})
          order_shipment = {}
          order_shipment["ins0:OrderId"]                = shipments[:order_id]
          order_shipment["ins0:ClientOrderIdentifier"]  = shipments[:client_order_id] if shipments[:client_order_id]
          order_shipment["ins0:ShipmentType"]           = shipments[:type] || "Full"

          if shipments[:type] == "Partial"
            partial_shipment = order_shipment["ins0:PartialShipment"] = {}
            shipment_contents = partial_shipment["ins0:shipmentContents"] = {}
            line_items = shipment_contents["ins0:LineItemList"] = {}
            line_item = line_items["ins0:LineItem"] = {}
            line_item["ins0:SKU"] = shipments[:line_items][0][:sku]
            line_item["ins0:Quantity"] = shipments[:line_items][0][:quantity]
            partial_shipment["ins0:dateShippedGMT"]       = shipments[:date]
            partial_shipment["ins0:carrierCode"]          = shipments[:carrier]
            partial_shipment["ins0:classCode"]            = shipments[:class]
            partial_shipment["ins0:trackingNumber"]       = shipments[:tracking_number]
            partial_shipment["ins0:sellerFulfillmentID"]  = shipments[:seller_id]
            partial_shipment["ins0:shipmentCost"]         = shipments[:cost]
            partial_shipment["ins0:shipmentTaxCost"]      = shipments[:tax]
            partial_shipment["ins0:insuranceCost"]        = shipments[:insurance]
          else
            full_shipment = order_shipment["ins0:FullShipment"] = {}
            full_shipment["ins0:dateShippedGMT"]          = shipments[:date] || DateTime.now
            full_shipment["ins0:carrierCode"]             = shipments[:carrier]         if shipments[:carrier]
            full_shipment["ins0:classCode"]               = shipments[:class]           if shipments[:class]
            full_shipment["ins0:trackingNumber"]          = shipments[:tracking_number] if shipments[:tracking_number]
            full_shipment["ins0:sellerFulfillmentID"]     = shipments[:seller_id]       if shipments[:seller_id]
            full_shipment["ins0:shipmentCost"]            = shipments[:cost]
            full_shipment["ins0:shipmentTaxCost"]         = shipments[:tax]
            full_shipment["ins0:insuranceCost"]           = shipments[:insurance]
          end


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
      end
    end
  end
end