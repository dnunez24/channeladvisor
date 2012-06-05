require 'spec_helper'

module ChannelAdvisor
  describe OrderStatus do
  	describe ".new" do
  		before(:each) do
        @attrs = {
		      :checkout_status => "Completed",
	        :checkout_date_gmt => DateTime.new(2012,05,17),
	        :payment_status => "Cleared",
	        :payment_date_gmt => DateTime.new(2012,05,17),
	        :shipping_status => "Shipped",
	        :shipping_date_gmt => DateTime.new(2012,05,21),
	        :order_refund_status => "NoRefunds"
      	}
      	@order_status = OrderStatus.new(@attrs)
  		end

  	  it "sets @checkout to an array of status and date" do
  	    @order_status.checkout.should == [@attrs[:checkout_status], @attrs[:checkout_date_gmt]]
  	  end

  	  it "sets @payment to an array of status and date" do
  	    @order_status.payment.should == [@attrs[:payment], @attrs[:payment_date_gmt]]
  	  end

  	  it "sets @shipping to an array of status and date" do
  	    @order_status.shipping.should == [@attrs[:shipping], @attrs[:shipping_date_gmt]]
  	  end

  	  it "sets @refund to the refund status" do
  	    @order_status.refund.should == @attrs[:order_refund_status]
  	  end
  	end
  end
end