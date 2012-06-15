require 'spec_helper'

module ChannelAdvisor
  module Services
    describe InventoryService do
      describe ".update_inventory_item_quantity_and_price" do
        use_vcr_cassette "responses/inventory_service/update_inventory_item_quantity_and_price"

        let(:quantity_info) do
          {
            :update_type  => "Absolute",
            :total        => 5000
          }
        end

        let(:price_info) do
          {
            :cost                       => 2.99,
            :retail_price               => 11.99,
            :starting_price             => 5.99,
            :reserve_price              => 7.99,
            :take_it_price              => 9.99,
            :second_chance_offer_price  => 8.99,
            :store_price                => 9.49
          }
        end

        before(:each) do
          @last_request, @last_response = nil

          InventoryService.client.config.hooks.define(:update_inventory_item_quantity_and_price, :soap_request) do |callback, request|
            @last_request = request.http
            @last_response = callback.call
          end
        end

        it "returns a SOAP response" do
          soap_response = InventoryService.update_inventory_item_quantity_and_price("FAKE001", :quantity_info => quantity_info, :price_info => price_info)
          soap_response.should be_a Savon::SOAP::Response
        end # returns a SOAP response

        context "with only quantity info" do
          use_vcr_cassette "responses/inventory_service/update_inventory_item_quantity_and_price/quantity_only"

          it "sends a valid SOAP request with only quantity info" do
            InventoryService.update_inventory_item_quantity_and_price("FAKE001", :quantity_info => quantity_info)
            @last_request.should match_valid_xml_body_for :update_item_quantity
          end
        end # with only quantity data

        context "with only price info" do
          use_vcr_cassette "responses/inventory_service/update_inventory_item_quantity_and_price/price_only"

          it "sends a valid SOAP request with only price info" do
            InventoryService.update_inventory_item_quantity_and_price("FAKE001", :price_info => price_info)
            @last_request.should match_valid_xml_body_for :update_item_price
          end
        end # with only price data

        context "with both quantity and price info" do
          use_vcr_cassette "responses/inventory_service/update_inventory_item_quantity_and_price/quantity_and_price"

          it "sends a valid SOAP request with both quantity and price info" do
            InventoryService.update_inventory_item_quantity_and_price("FAKE001", :quantity_info => quantity_info, :price_info => price_info)
            @last_request.should match_valid_xml_body_for :update_item_quantity_and_price
          end
        end # with only price data
      end # .update_inventory_item_quantity_and_price
    end # InventoryService
  end # Services
end # ChannelAdvisor