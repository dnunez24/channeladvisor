require 'spec_helper'

module ChannelAdvisor
	describe LineItem do
		let(:attrs) do
      {
      	:line_item_type => "SKU",
        :unit_price => "6.9900",
        :line_item_id => "17293910",
        :allow_negative_quantity => false,
        :quantity => "5",
        :item_sale_source => "DIRECT_SALE",
        :sku => "FAKE001",
        :title => "Fake Item No. 1",
        :buyer_user_id => "test@example.com",
        :buyer_feedback_rating => "0",
        :sales_source_id => "37081357",
        :vat_rate => "0",
        :tax_cost => "0.0000",
        :shipping_cost => "0.0000",
        :shipping_tax_cost => "0.0000",
        :gift_wrap_cost => "0.0000",
        :gift_wrap_tax_cost => "0.0000",
        :gift_message => "Example gift message",
        :gift_wrap_level => "Some Level",
        :recycling_fee => "0.0000",
        :unit_weight => "1.2",
        :warehouse_location => "A14",
        :user_name => "somebody",
        :distribution_center_code => "ABC",
        :is_fba => false,
        :promo_code => "ABC123",
        :"@xsi:type" => "q1:OrderLineItemItemResponse"
      }
		end

		before(:each) do
		  @line_item = LineItem.new(attrs)
		end

		describe ".new" do
		  it "sets @type" do
		    @line_item.type.should == attrs[:line_item_type]
		  end

		  it "sets @id" do
		    @line_item.id.should == attrs[:line_item_id]
		  end

		  it "sets @unit_price" do
		    @line_item.unit_price.should == attrs[:unit_price].to_f
		  end

		  it "sets @allow_negative_quantity" do
		    @line_item.allow_negative_quantity.should == attrs[:allow_negative_quantity]
		  end

		  it "sets @quantity" do
		    @line_item.quantity.should == attrs[:quantity].to_i
		  end

		  it "sets @sale_source" do
		    @line_item.sale_source.should == attrs[:item_sale_source]
		  end

		  it "sets @sku" do
		    @line_item.sku.should == attrs[:sku]
		  end

		  it "sets @title" do
		    @line_item.title.should == attrs[:title]
		  end

		  it "sets @buyer_user_id" do
		    @line_item.buyer_user_id.should == attrs[:buyer_user_id]
		  end

		  it "sets @buyer_feedback_rating" do
		  	@line_item.buyer_feedback_rating.should == attrs[:buyer_feedback_rating] 
		  end

		  it "sets @sales_source_id" do
		    @line_item.sales_source_id.should == attrs[:sales_source_id]
		  end

		  it "sets @vat_rate" do
		    @line_item.vat_rate.should == attrs[:vat_rate].to_f
		  end

		  it "sets @tax_cost" do
		    @line_item.tax_cost.should == attrs[:tax_cost].to_f
		  end

		  it "sets @shipping_cost" do
		    @line_item.shipping_cost.should == attrs[:shipping_cost].to_f
		  end

		  it "sets @shipping_tax_cost" do
		    @line_item.shipping_tax_cost.should == attrs[:shipping_tax_cost].to_f
		  end

		  it "sets @gift_wrap_cost" do
		    @line_item.gift_wrap_cost.should == attrs[:gift_wrap_cost].to_f
		  end

		  it "sets @gift_wrap_tax_cost" do
		    @line_item.gift_wrap_tax_cost.should == attrs[:gift_wrap_tax_cost].to_f
		  end

		  it "sets @gift_message" do
		    @line_item.gift_message.should == attrs[:gift_message]
		  end

		  it "sets @gift_wrap_level" do
		    @line_item.gift_wrap_level.should == attrs[:gift_wrap_level]
		  end

		  it "sets @recycling_fee" do
		    @line_item.recycling_fee.should == attrs[:recycling_fee].to_f
		  end

		  it "sets @unit_weight" do
		    @line_item.unit_weight.should == attrs[:unit_weight].to_f
		  end

		  it "sets @warehouse_location" do
		    @line_item.warehouse_location.should == attrs[:warehouse_location]
		  end

		  it "sets @user_name" do
		    @line_item.user_name.should == attrs[:user_name]
		  end

		  it "sets @distribution_center_code" do
		    @line_item.distribution_center.should == attrs[:distribution_center_code]
		  end

		  it "sets @is_fba" do
		    @line_item.is_fba.should == attrs[:is_fba]
		  end

		  it "sets @promo_code" do
		    @line_item.promo_code.should == attrs[:promo_code]
		  end
		end
	end # LineItem
end # ChannelAdvisor