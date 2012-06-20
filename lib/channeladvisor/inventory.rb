module ChannelAdvisor
  class Inventory < Base

    # Update the quantity and/or price data for inventory items
    #
    # @raise [ServiceFailure] If the service returns a Failure status
    # @raise [SOAPFault] If the service responds with a SOAP fault
    # @raise [HTTPError] If the service responds with an HTTP error
    #
    # @return [Hash] A hash with true/false keys corresponding to an array of SKUs that returned the given result
    def self.update_quantity_and_price(*items)
      handle_errors do
        if items.count > 1
          response = Services::InventoryService.update_inventory_item_quantity_and_price_list([*items])
          result = response[:update_inventory_item_quantity_and_price_list_response][:update_inventory_item_quantity_and_price_list_result]
        else
          response = Services::InventoryService.update_inventory_item_quantity_and_price(*items)
          result = response[:update_inventory_item_quantity_and_price_response][:update_inventory_item_quantity_and_price_result]
        end

        check_status_of result

        result_data = result[:result_data]
        return result_data unless result_data.is_a? Hash

        result_hash = {
          true => [],
          false => []
        }

        result_data[:update_inventory_item_response].each do |item|
          result_hash[item[:result]] << item[:sku]
        end

        return result_hash
      end
    end
  end
end