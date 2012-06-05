require 'spec_helper'

module ChannelAdvisor
  describe Shipment do
    describe ".new" do
      before(:each) do
        @attrs = {
          :shipping_carrier => "UPS",
          :shipping_class => "Ground",
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
    end
  end
end