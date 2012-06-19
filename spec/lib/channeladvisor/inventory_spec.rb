require 'spec_helper'

module ChannelAdvisor
  describe Inventory do
    describe ".update_quantity_and_price" do
      let(:item1) do
        {
          :sku => "FAKE001",
          :quantity_info => {
            :update_type  => "Absolute",
            :total        => 5000
          },
          :price_info => {
            :cost                       => 2.99,
            :retail_price               => 11.99,
            :starting_price             => 5.99,
            :reserve_price              => 7.99,
            :take_it_price              => 9.99,
            :second_chance_offer_price  => 8.99,
            :store_price                => 9.49
          }
        }
      end

      let(:item2) do
        {
          :sku => "FAKE002",
          :quantity_info => {
            :update_type  => "Absolute",
            :total        => 7500
          },
          :price_info => {
            :cost                       => 3.99,
            :retail_price               => 10.99,
            :starting_price             => 4.99,
            :reserve_price              => 7.99,
            :take_it_price              => 8.99,
            :second_chance_offer_price  => 6.99,
            :store_price                => 8.49
          }
        }
      end


      context "with one item" do
        use_vcr_cassette "responses/inventory/update_quantity_and_price/with_one_item", :allow_playback_repeats => true

        it "sends a request to the inventory update service with one item" do
          stub.proxy(Services::InventoryService).update_inventory_item_quantity_and_price
          Inventory.update_quantity_and_price(item1)
          Services::InventoryService.should have_received.update_inventory_item_quantity_and_price(item1)
        end

        it "returns a boolean response" do
          response = Inventory.update_quantity_and_price(item1)
          response.should be_a_boolean
        end
      end

      context "with two items" do
        use_vcr_cassette "responses/inventory/update_quantity_and_price/with_two_items", :allow_playback_repeats => true

        it "sends a request to the inventory update service with two items" do
          stub.proxy(Services::InventoryService).update_inventory_item_quantity_and_price_list
          Inventory.update_quantity_and_price(item1, item2)
          Services::InventoryService.should have_received.update_inventory_item_quantity_and_price_list([item1, item2])
        end

        context "with a true and false result" do
          it "returns a hash of boolean responses" do
            results = {
              true => [item1[:sku]],
              false => [item2[:sku]]
            }
            response = Inventory.update_quantity_and_price(item1, item2)
            response.should == results
          end
        end

        context "with all true results" do
          use_vcr_cassette "responses/inventory/update_quantity_and_price/with_two_items/both_true", :allow_playback_repeats => true

          it "returns a hash where false is an empty array" do
            results = {
              true => [item1[:sku], item2[:sku]],
              false => []
            }
            response = Inventory.update_quantity_and_price(item1, item2)
            response.should == results
          end
        end

        context "with all false results" do
          use_vcr_cassette "responses/inventory/update_quantity_and_price/with_two_items/both_false", :allow_playback_repeats => true

          it "returns a hash where true is an empty array" do
            results = {
              true => [],
              false => [item1[:sku], item2[:sku]]
            }
            response = Inventory.update_quantity_and_price(item1, item2)
            response.should == results
          end
        end
      end

      context "with a Failure status" do
        use_vcr_cassette "responses/inventory/update_quantity_and_price/failure", :allow_playback_repeats => true

        it "raises a ServiceFailure error" do
          expect { Inventory.update_quantity_and_price(item1) }.to raise_error ServiceFailure
        end
      end

      context "with a SOAP fault" do
        use_vcr_cassette "responses/soap_fault", :match_requests_on => [:method], :allow_playback_repeats => true

        it "raises a SOAP fault error" do
          expect { Inventory.update_quantity_and_price(item1) }.to raise_error SOAPFault, "Server was unable to process request. Authentication failed."
        end

        it "stores the SOAP fault code" do
          begin
            Inventory.update_quantity_and_price(item1)
          rescue SOAPFault => fault
            fault.code.should == "soap:Server"
          end
        end
      end # with a SOAP Fault

      context "with an HTTP error" do
        http_status = {:code => 500, :message => "Internal Server Error"}
        use_vcr_cassette "responses/http_error", :match_requests_on => [:method], :erb => http_status, :allow_playback_repeats => true

        it "raises an HTTP error" do
          expect { Inventory.update_quantity_and_price(item1) }.to raise_error HTTPError, "Failed with HTTP error #{http_status[:code]}"
        end

        it "stores the HTTP status code" do
          begin
            Inventory.update_quantity_and_price(item1)
          rescue HTTPError => error
            error.code.should == http_status[:code]
          end
        end
      end # with an HTTP error
    end # .update_quantity_and_price
  end # Inventory
end # ChannelAdvisor
