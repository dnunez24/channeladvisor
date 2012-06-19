module ChannelAdvisor
  class Inventory < Base
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