require 'spec_helper'
module ChannelAdvisor
  describe LineItemPromo do 
    let(:attrs) do
      {
        :line_item_type => "Promotion",
        :unit_price => -3.89,
        :promo_code => "FREESTUFF",
        :shipping_price => -12.89
      }
    end

    before(:each) do 
      @line_item_promo = LineItemPromo.new(attrs)
    end
    describe ".new" do 
      it "sets @line_item_type" do
        @line_item_promo.line_item_type.should == attrs[:line_item_type]
      end
      it "sets @unit_price" do 
        @line_item_promo.unit_price.should == attrs[:unit_price]
      end
      it "sets @promo_code" do 
        @line_item_promo.promo_code.should == attrs[:promo_code]
      end
      it "sets @shipping_price" do 
        @line_item_promo.shipping_price.should == attrs[:shipping_price]
      end
    end
  end
end