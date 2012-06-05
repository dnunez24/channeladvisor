require 'spec_helper'

module ChannelAdvisor
	describe Payment do
		describe ".new" do
			before(:each) do
        @attrs = {
          :payment_type => "Credit Card",
          :credit_card_last4 => "1234",
          :pay_pal_id => "ABCDEFG123456",
          :merchant_reference_number => "99999",
          :payment_transaction_id => "XYZ999999999"
        }
        @payment = Payment.new(@attrs)
			end

		  it "sets @type" do
		    @payment.type.should == @attrs[:payment_type]
		  end

		  it "sets @credit_card_last4" do
		    @payment.credit_card_number.should == @attrs[:credit_card_last4]
		  end

		  it "sets @paypal_id" do
		    @payment.paypal_id.should == @attrs[:pay_pal_id]
		  end

		  it "sets @merchant_reference_number" do
		    @payment.merchant_reference_number.should == @attrs[:merchant_reference_number]
		  end

		  it "sets @payment_transaction_id" do
		    @payment.transaction_id.should == @attrs[:payment_transaction_id]
		  end
		end
	end
end