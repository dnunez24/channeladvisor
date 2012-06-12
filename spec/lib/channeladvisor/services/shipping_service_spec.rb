require 'spec_helper'
require 'timecop'

module ChannelAdvisor
  module Services
    describe ShippingService do
      subject { ShippingService }

      describe ".ping" do
        context "when successful" do
          use_vcr_cassette "responses/shipping_service/ping/success"
          before(:each) { ShippingService.ping }

          its(:last_request)  { should match_valid_xml_body_for :ping }
          its(:last_request)  { should be_an HTTPI::Request }
          its(:last_response) { should be_a Savon::SOAP::Response }
        end

        context "when unsuccessful" do
          use_vcr_cassette "responses/shipping_service/ping/failure"

          it "should raise a SOAP Fault error" do
            ChannelAdvisor.configure { |config| config.password = "wrong password" }
            expect { ShippingService.ping }.to raise_error Savon::SOAP::Fault
          end
        end
      end # .ping

      describe ".submit_order_shipment_list" do
        use_vcr_cassette "responses/shipping_service/submit_order_shipment_list", :allow_playback_repeats => true

        before(:each) do
          @last_request = nil
          @last_response = nil

          ShippingService.client.config.hooks.define(:submit_order_shipment_list, :soap_request) do |callback, request|
            @last_request = request.http
            @last_response = callback.call
          end
        end

        context "with full shipments" do
          let(:full_shipment) do
            {
              :order_id => 123456,
              :client_order_id => "ABCD1234",
              :date => DateTime.new(2012,05,19),
              :carrier => "UPS",
              :class => "GND",
              :tracking_number => "1ZABCE09813473497",
              :seller_id => "999999",
              :cost => 5.99,
              :tax => 1.99,
              :insurance => 2.99
            }
          end

          context "with one full shipment" do
            it "sends a valid SOAP request with full shipment data" do
              ShippingService.submit_order_shipment_list([full_shipment])
              @last_request.should match_valid_xml_body_for "submit_order_shipment_list/full_shipment/with_one_shipment"
            end

            context "without a type" do
              it "defaults to a full shipment update" do
                full_shipment.delete(:type)
                ShippingService.submit_order_shipment_list([full_shipment])
                @last_request.body.should match /<ins0:ShipmentType>Full<\/ins0:ShipmentType>/
              end
            end

            context "without a shipping date" do
              it "defaults to the current date and time" do
                full_shipment.delete(:date)
                ShippingService.submit_order_shipment_list([full_shipment])
                ::Timecop.freeze(DateTime.now) do
                  @last_request.body.should match /<ins0:dateShippedGMT>#{DateTime.now}<\/ins0:dateShippedGMT>/
                end
              end
            end

            context "without a client order ID" do
              it "sends a valid SOAP request without the client order ID" do
                full_shipment.delete(:client_order_id)
                ShippingService.submit_order_shipment_list([full_shipment])
                @last_request.should match_valid_xml_body_for "submit_order_shipment_list/full_shipment/without_client_order_id"
              end
            end

            context "without a carrier code" do
              it "sends a valid SOAP request without the carrier code" do
                full_shipment.delete(:carrier)
                ShippingService.submit_order_shipment_list([full_shipment])
                @last_request.should match_valid_xml_body_for "submit_order_shipment_list/full_shipment/without_carrier_code"
              end
            end

            context "without a class code" do
              it "sends a valid SOAP request without the class code" do
                full_shipment.delete(:class)
                ShippingService.submit_order_shipment_list([full_shipment])
                @last_request.should match_valid_xml_body_for "submit_order_shipment_list/full_shipment/without_class_code"
              end
            end

            context "without a tracking number" do
              it "sends a valid SOAP request without the tracking number" do
                full_shipment.delete(:tracking_number)
                ShippingService.submit_order_shipment_list([full_shipment])
                @last_request.should match_valid_xml_body_for "submit_order_shipment_list/full_shipment/without_tracking_number"
              end
            end

            context "without a seller fulfillment ID" do
              it "sends a valid SOAP request without the seller fulfillment ID" do
                full_shipment.delete(:seller_id)
                ShippingService.submit_order_shipment_list([full_shipment])
                @last_request.should match_valid_xml_body_for "submit_order_shipment_list/full_shipment/without_seller_id"
              end
            end
          end # with one full shipment

          context "with two full shipments" do
            it "sends a valid SOAP request with two full shipments" do
              shipments = []
              second_shipment = {
                :order_id => 567890,
                :client_order_id => "EFGH1234",
                :date => DateTime.new(2012,05,21),
                :carrier => "FEDEX",
                :class => "GROUND",
                :tracking_number => "1234567890",
                :seller_id => "555555",
                :cost => 7.50,
                :tax => 1.50,
                :insurance => 2.50
              }
              shipments << full_shipment
              shipments << second_shipment
              ShippingService.submit_order_shipment_list(shipments)
              @last_request.should match_valid_xml_body_for "submit_order_shipment_list/full_shipment/with_two_shipments"
            end
          end # with two full shipments
        end # with full shipments

        context "with partial shipments" do
          let(:partial_shipment) do
            {
              :order_id => 123456,
              :client_order_id => "ABCD1234",
              :line_items => [{:sku => "ABCD", :quantity => 5}],
              :date => DateTime.new(2012,05,19),
              :carrier => "UPS",
              :class => "GND",
              :tracking_number => "1ZABCE09813473497",
              :seller_id => "999999",
              :cost => 5.99,
              :tax => 1.99,
              :insurance => 2.99
            }
          end

          context "with one partial shipment" do
            context "with one line item" do
              it "sends a valid SOAP request with one line item" do
                ShippingService.submit_order_shipment_list([partial_shipment])
                @last_request.should match_valid_xml_body_for "submit_order_shipment_list/partial_shipment/with_one_line_item"
              end

              context "without a shipping date" do
                it "defaults to the current date and time" do
                  partial_shipment.delete(:date)
                  ShippingService.submit_order_shipment_list([partial_shipment])
                  ::Timecop.freeze(DateTime.now) do
                    @last_request.body.should match /<ins0:dateShippedGMT>#{DateTime.now}<\/ins0:dateShippedGMT>/
                  end
                end
              end

              context "without a carrier code" do
                it "sends a valid SOAP request without the carrier code" do
                  partial_shipment.delete(:carrier)
                  ShippingService.submit_order_shipment_list([partial_shipment])
                  @last_request.should match_valid_xml_body_for "submit_order_shipment_list/partial_shipment/without_carrier_code"
                end
              end

              context "without a class code" do
                it "sends a valid SOAP request without the class code" do
                  partial_shipment.delete(:class)
                  ShippingService.submit_order_shipment_list([partial_shipment])
                  @last_request.should match_valid_xml_body_for "submit_order_shipment_list/partial_shipment/without_class_code"
                end
              end

              context "without a tracking number" do
                it "sends a valid SOAP request without the tracking number" do
                  partial_shipment.delete(:tracking_number)
                  ShippingService.submit_order_shipment_list([partial_shipment])
                  @last_request.should match_valid_xml_body_for "submit_order_shipment_list/partial_shipment/without_tracking_number"
                end
              end

              context "without a seller fulfillment ID" do
                it "sends a valid SOAP request without the seller fulfillment ID" do
                  partial_shipment.delete(:seller_id)
                  ShippingService.submit_order_shipment_list([partial_shipment])
                  @last_request.should match_valid_xml_body_for "submit_order_shipment_list/partial_shipment/without_seller_id"
                end
              end
            end

            context "with two line items" do
              it "sends a valid SOAP request with two line items" do
                partial_shipment[:line_items] << {:sku => "EFGH", :quantity => 3}
                ShippingService.submit_order_shipment_list([partial_shipment])
                @last_request.should match_valid_xml_body_for "submit_order_shipment_list/partial_shipment/with_two_line_items"
              end
            end
          end # with one partial shipment

          context "with two partial shipments" do
            it "sends a valid SOAP request with two partial shipments" do
              shipments = []
              second_shipment = {
                :order_id => 567890,
                :client_order_id => "EFGH1234",
                :line_items => [{:sku => "EFGH", :quantity => 3}],
                :date => DateTime.new(2012,05,21),
                :carrier => "FEDEX",
                :class => "GROUND",
                :tracking_number => "1234567890",
                :seller_id => "555555",
                :cost => 7.50,
                :tax => 1.50,
                :insurance => 2.50
              }
              shipments << partial_shipment
              shipments << second_shipment
              ShippingService.submit_order_shipment_list(shipments)
              @last_request.should match_valid_xml_body_for "submit_order_shipment_list/partial_shipment/with_two_shipments"
            end
          end # with two partial shipments
        end # with partial shipments

        context "with both partial and full shipments" do
          it "sends a valid SOAP request with two partial shipments" do
            shipments = []
            full_shipment = {
              :order_id => 123456,
              :client_order_id => "ABCD1234",
              :date => DateTime.new(2012,05,19),
              :carrier => "UPS",
              :class => "GND",
              :tracking_number => "1ZABCE09813473497",
              :seller_id => "999999",
              :cost => 5.99,
              :tax => 1.99,
              :insurance => 2.99
            }
            partial_shipment = {
              :order_id => 567890,
              :client_order_id => "EFGH1234",
              :line_items => [{:sku => "EFGH", :quantity => 3}],
              :date => DateTime.new(2012,05,21),
              :carrier => "FEDEX",
              :class => "GROUND",
              :tracking_number => "1234567890",
              :seller_id => "555555",
              :cost => 7.50,
              :tax => 1.50,
              :insurance => 2.50
            }
            shipments << full_shipment
            shipments << partial_shipment
            ShippingService.submit_order_shipment_list(shipments)
            @last_request.should match_valid_xml_body_for "submit_order_shipment_list/with_partial_and_full_shipments"
          end
        end # with both full and partial shipments
      end
    end # ShippingService
  end # Services
end # ChannelAdvisor