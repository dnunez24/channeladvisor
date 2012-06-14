require 'spec_helper'

module ChannelAdvisor
	module Services
		describe InventoryService do
			describe ".update_inventory_item_quantity_and_price" do
        before(:each) do
          @last_request, @last_response = nil

          InventoryService.client.config.hooks.define(:update_inventory_item_quantity_and_price, :soap_request) do |callback, request|
            @last_request = request.http
            @last_response = callback.call
          end
        end

        context "with only quantity info" do
        	use_vcr_cassette "responses/inventory_service/update_item_quantity"

				  it "sends a valid SOAP request with only quantity info" do
				  	quantity_info = {
				  		:update_type 	=> "Absolute",
				  		:total 				=> 5000
				  	}
				    InventoryService.update_inventory_item_quantity_and_price("FAKE001", :quantity_info => quantity_info)
				    @last_request.should match_valid_xml_body_for :update_item_quantity
				  end
        end # with only quantity data

        context "with only price info" do
        	use_vcr_cassette "responses/inventory_service/update_item_price"

				  it "sends a valid SOAP request with only price info" do
				  	price_info = {
				  		:cost 											=> 2.99,
				  		:retail_price 							=> 11.99,
				  		:starting_price 						=> 5.99,
				  		:reserve_price 							=> 7.99,
				  		:take_it_price 							=> 9.99,
				  		:second_chance_offer_price 	=> 8.99,
				  		:store_price 								=> 9.49
				  	}
				    InventoryService.update_inventory_item_quantity_and_price("FAKE001", :price_info => price_info)
				    @last_request.should match_valid_xml_body_for :update_item_price
				  end
        end # with only price data
			end # .update_inventory_item_quantity_and_price
		end # InventoryService
	end # Services
end # ChannelAdvisor