require 'spec_helper'
require 'timecop'

module ChannelAdvisor
  describe Shipment do
    describe ".new" do
      before(:each) do
        @attrs = {
          :shipping_carrier => "UPS",
          :shipping_class => "GND",
          :tracking_number => "1234567890"
        }
        @shipment = Shipment.new(@attrs)
      end

      it "sets @shipping_carrier" do
        @shipment.shipping_carrier.should == @attrs[:shipping_carrier]
      end

      it "sets @shipping_class" do
        @shipment.shipping_class.should == @attrs[:shipping_class]
      end

      it "sets @tracking_number" do
        @shipment.tracking_number.should == @attrs[:tracking_number]
      end
    end # .new

    describe ".submit" do
      use_vcr_cassette "responses/shipment/submit", :allow_playback_repeats => true
      before { stub.proxy(Services::ShippingService).submit_order_shipment_list }

      let(:original_shipment) do
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

      context "with one shipment" do
        use_vcr_cassette "responses/shipment/submit/one_shipment"

        let(:actual_shipment) { original_shipment.dup }
        before do
          actual_shipment[:type]       = "Full"
          actual_shipment[:cost]       = "%.2f" % actual_shipment[:cost]
          actual_shipment[:tax]        = "%.2f" % actual_shipment[:tax]
          actual_shipment[:insurance]  = "%.2f" % actual_shipment[:insurance]
        end

        it "sends one shipment to the shipping service" do
          Shipment.submit(original_shipment)
          Services::ShippingService.should have_received.submit_order_shipment_list([actual_shipment])
        end

        it "returns a boolean result" do
          response = Shipment.submit(original_shipment)
          response.should be_a_boolean
        end

        context "without a ship date" do
          it "sends a shipment with the current date" do
            original_shipment.delete(:date)
            ::Timecop.freeze(DateTime.now) do
              actual_shipment[:date] = DateTime.now
              Shipment.submit(original_shipment)
              Services::ShippingService.should have_received.submit_order_shipment_list([actual_shipment])
            end
          end
        end

        context "without a ship cost" do
          it "sends a shipment cost that is nil" do
            original_shipment.delete(:cost)
            actual_shipment[:cost] = nil
            Shipment.submit(original_shipment)
            Services::ShippingService.should have_received.submit_order_shipment_list([actual_shipment])
          end
        end

        context "without a tax cost" do
          it "sends a shipment with a tax cost of nil" do
            original_shipment.delete(:tax)
            actual_shipment[:tax] = nil
            Shipment.submit(original_shipment)
            Services::ShippingService.should have_received.submit_order_shipment_list([actual_shipment])
          end
        end

        context "without an insurance cost" do
          it "sends a shipment with an insurance cost of nil" do
            original_shipment.delete(:insurance)
            actual_shipment[:insurance] = nil
            Shipment.submit(original_shipment)
            Services::ShippingService.should have_received.submit_order_shipment_list([actual_shipment])
          end
        end

        context "with line items" do
          it "sends a partial shipment" do
            actual_shipment[:line_items] = original_shipment[:line_items] = [{:sku => "ABCD", :quantity => 5}]
            actual_shipment[:type] = "Partial"
            Shipment.submit(original_shipment)
            Services::ShippingService.should have_received.submit_order_shipment_list([actual_shipment])
          end
        end
      end # with one shipment

      context "with two shipments" do
        use_vcr_cassette "responses/shipment/submit/two_shipments", :allow_playback_repeats => true

        let(:shipment1) { original_shipment.dup }
        let(:shipment2) do
          {
            :order_id => 567890,
            :client_order_id => "EFGH1234",
            :date => DateTime.new(2012,05,19),
            :carrier => "USPS",
            :class => "PRIORITY",
            :tracking_number => "99999000000000",
            :seller_id => "555555",
            :cost => 5.99,
            :tax => 1.99,
            :insurance => 2.99
          }
        end
        let(:shipments) { [shipment1, shipment2] }
        before :each do 
          @false_msg = "An unexpected error occurred involving Order 123456.  Please make sure sufficient unshipped quantity exists on the order and that the Carrier and Class Codes are valid."
        end
        it "sends two shipments to the shipping service" do
          Shipment.submit(shipments)
          Services::ShippingService.should have_received.submit_order_shipment_list(shipments)
        end

        context "with a true and false result" do
          it "returns an array of hashes with their sucess fields set to true or false " do
            result =[
              {
                :order_id => shipment1[:order_id],
                :success  => false,
                :message  => @false_msg
              },
              {
                :order_id =>shipment2[:order_id],
                :success  => true
              }]
            response = Shipment.submit(shipments)
            response.should == result
          end
        end

        context "with all true results" do
          use_vcr_cassette "responses/shipment/submit/two_shipments/both_true", :exclusive => true, :allow_playback_repeats => true

          it "returns an array of hashes with success = true" do
            result =[
              {
                :order_id => shipment1[:order_id],
                :success  => true
              },
              {
                :order_id =>shipment2[:order_id],
                :success  => true
              }]
            response = Shipment.submit(shipments)
            response.should == result
          end
        end

        context "with all false results" do
          use_vcr_cassette "responses/shipment/submit/two_shipments/both_false", :exclusive => true, :allow_playback_repeats => true

          it "returns an array of hashes with success = false, also returns an error message  " do
            result =[
              {
                :order_id => shipment1[:order_id],
                :success  => false,
                :message  => @false_msg
              },
              {
                :order_id =>shipment2[:order_id],
                :success  => false,
                :message  => @false_msg
              }]
            response = Shipment.submit(shipments)
            response.should == result
          end
        end
      end # with two shipments

      context "with a Failure status" do
        use_vcr_cassette "responses/shipment/submit/failure", :allow_playback_repeats => true

        it "raises a ServiceFailure error" do
          expect { Shipment.submit(original_shipment) }.to raise_error ServiceFailure
        end
      end

      context "with a SOAP fault" do
        use_vcr_cassette "responses/soap_fault", :match_requests_on => [:method], :allow_playback_repeats => true

        it "raises a SOAP fault error" do
          expect { Shipment.submit(original_shipment) }.to raise_error SOAPFault, "Server was unable to process request. Authentication failed."
        end

        it "stores the SOAP fault code" do
          begin
            Shipment.submit(original_shipment)
          rescue SOAPFault => fault
            fault.code.should == "soap:Server"
          end
        end
      end # with a SOAP Fault

      context "with an HTTP error" do
        http_status = {:code => 500, :message => "Internal Server Error"}
        use_vcr_cassette "responses/http_error", :match_requests_on => [:method], :erb => http_status, :allow_playback_repeats => true

        it "raises an HTTP error" do
          expect { Shipment.submit(original_shipment) }.to raise_error HTTPError, "Failed with HTTP error #{http_status[:code]}"
        end

        it "stores the HTTP status code" do
          begin
            Shipment.submit(original_shipment)
          rescue HTTPError => error
            error.code.should == http_status[:code]
          end
        end
      end # with an HTTP error
    end # .submit

    describe ".get_carriers" do
      use_vcr_cassette "responses/shipment/get_carriers", :allow_playback_repeats => true

      it "calls the get_shipping_carrier_list" do
        stub.proxy(Services::ShippingService).get_shipping_carrier_list
        Shipment.get_carriers
        Services::ShippingService.should have_received.get_shipping_carrier_list
      end

      it "returns an array of shipping carrier hashes" do
        results = Shipment.get_carriers
        results.each do |carrier_data|
          carrier_data.should include(
            :carrier_id,
            :class_id,
            :carrier_name,
            :carrier_code,
            :class_code,
            :class_name
          )
        end
      end

      context "with a Failure status" do
        use_vcr_cassette "responses/shipment/get_carriers/failure", :allow_playback_repeats => true

        it "raises a ServiceFailure error" do
          expect { Shipment.get_carriers }.to raise_error ServiceFailure
        end
      end

      context "with a SOAP fault" do
        use_vcr_cassette "responses/soap_fault", :match_requests_on => [:method], :allow_playback_repeats => true

        it "raises a SOAP fault error" do
          expect { Shipment.get_carriers }.to raise_error SOAPFault, "Server was unable to process request. Authentication failed."
        end

        it "stores the SOAP fault code" do
          begin
            Shipment.get_carriers
          rescue SOAPFault => fault
            fault.code.should == "soap:Server"
          end
        end
      end # with a SOAP Fault

      context "with an HTTP error" do
        http_status = {:code => 500, :message => "Internal Server Error"}
        use_vcr_cassette "responses/http_error", :match_requests_on => [:method], :erb => http_status, :allow_playback_repeats => true

        it "raises an HTTP error" do
          expect { Shipment.get_carriers }.to raise_error HTTPError, "Failed with HTTP error #{http_status[:code]}"
        end

        it "stores the HTTP status code" do
          begin
            Shipment.get_carriers
          rescue HTTPError => error
            error.code.should == http_status[:code]
          end
        end
      end # with an HTTP error
    end # .get_carriers
  end # Shipment
end # ChannelAdvisor