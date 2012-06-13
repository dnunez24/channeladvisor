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
      let(:old_shipment) do
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

      before { stub(Services::ShippingService).submit_order_shipment_list }

      context "with one shipment" do
        let(:new_shipment) { old_shipment.dup }
        before do
          new_shipment[:type]       = "Full"
          new_shipment[:cost]       = "%.2f" % new_shipment[:cost]
          new_shipment[:tax]        = "%.2f" % new_shipment[:tax]
          new_shipment[:insurance]  = "%.2f" % new_shipment[:insurance]
        end

        it "sends one shipment to the shipping service" do
          Shipment.submit(old_shipment)
          Services::ShippingService.should have_received.submit_order_shipment_list([new_shipment])
        end

        context "without a ship date" do
          it "sends a shipment with the current date" do
            old_shipment.delete(:date)
            ::Timecop.freeze(DateTime.now) do
              new_shipment[:date] = DateTime.now
              Shipment.submit(old_shipment)
              Services::ShippingService.should have_received.submit_order_shipment_list([new_shipment])
            end
          end
        end

        context "without a ship cost" do
          it "sends a shipment with a shipping cost of 0.00" do
            old_shipment.delete(:cost)
            new_shipment[:cost] = "0.00"
            Shipment.submit(old_shipment)
            Services::ShippingService.should have_received.submit_order_shipment_list([new_shipment])
          end
        end

        context "without a tax cost" do
          it "sends a shipment with a tax cost of 0.00" do
            old_shipment.delete(:tax)
            new_shipment[:tax] = "0.00"
            Shipment.submit(old_shipment)
            Services::ShippingService.should have_received.submit_order_shipment_list([new_shipment])
          end
        end

        context "without an insurance cost" do
          it "sends a shipment with an insurance cost of 0.00" do
            old_shipment.delete(:insurance)
            new_shipment[:insurance] = "0.00"
            Shipment.submit(old_shipment)
            Services::ShippingService.should have_received.submit_order_shipment_list([new_shipment])
          end
        end

        context "with line items" do
          it "sends a partial shipment" do
            new_shipment[:line_items] = old_shipment[:line_items] = {:sku => "ABCD", :quantity => 5}
            new_shipment[:type] = "Partial"
            Shipment.submit(old_shipment)
            Services::ShippingService.should have_received.submit_order_shipment_list([new_shipment])
          end
        end
      end # with one shipment

      context "with two shipments" do
        let(:shipment1) { old_shipment.dup }
        let(:shipment2) { old_shipment.dup }

        it "sends two shipments to the shipping service" do
          shipments = [shipment1, shipment2]
          Shipment.submit(shipments)
          Services::ShippingService.should have_received.submit_order_shipment_list(shipments)
        end
      end
    end # .submit
  end # Shipment
end # ChannelAdvisor