require 'spec_helper'

module ChannelAdvisor
  describe ShoppingCart do
    describe ".new" do
      let(:attrs) do
        {
          :cart_id => "14161613",
          :checkout_source => "Unspecified",
          :vat_tax_calculation_option => "Unspecified",
          :vat_shipping_option => "Unspecified",
          :vat_gift_wrap_option => "Unspecified",
          :line_item_sku_list => {
            :order_line_item_item => {:line_item_id => "17293910"}
          },
          :line_item_invoice_list => {
            :order_line_item_invoice => {:line_item_type => "SalesTax", :unit_price => "0.0000"}
          },
          :line_item_promo_list => {
            :order_line_item_promo => {:line_item_type => "Promotion", :unit_price => "0.0000", :promo_code => nil}
          }
        }
      end

      before(:each) do
        @shopping_cart = ShoppingCart.new(attrs)
      end

      it "sets @id" do
        @shopping_cart.id.should == attrs[:cart_id]
      end

      it "sets @checkout_source" do
        @shopping_cart.checkout_source.should == attrs[:checkout_source]
      end

      it "sets @vat_tax_calculation_option" do
        @shopping_cart.vat_tax_calculation_option.should == attrs[:vat_tax_calculation_option]
      end

      it "sets @vat_shipping_option" do
        @shopping_cart.vat_shipping_option.should == attrs[:vat_shipping_option]
      end

      it "sets @vat_gift_wrap_option" do
        @shopping_cart.vat_gift_wrap_option.should == attrs[:vat_gift_wrap_option]
      end

      context "with one item" do
        before(:each) do
          stub.proxy(LineItem).new
          @shopping_cart = ShoppingCart.new(attrs)
        end

        it "creates a @line_items collection with one line item" do
          @shopping_cart.items.should have(1).item
          @shopping_cart.items.first.should be_a LineItem
        end

        it "creates a new line item object for the line item in the attribute hash" do
          item = attrs[:line_item_sku_list][:order_line_item_item]
          LineItem.should have_received.new(item)
        end
      end

      context "with two items" do
        before(:each) do
          @items = attrs[:line_item_sku_list][:order_line_item_item] = [
            {:line_item_id => "17293910"},
            {:line_item_id => "17293911"}
          ]
          stub.proxy(LineItem).new
          @shopping_cart = ShoppingCart.new(attrs)
        end

        it "creates a @line_items collection with two line items" do
          @shopping_cart.items.should have(2).line_items
          @shopping_cart.items.each do |item|
            item.should be_a LineItem
          end
        end

        it "creates a new line item object for each line item in the attribute hash" do
          @items.each do |item|
            LineItem.should have_received.new(item)
          end
        end
      end

      context "with one invoice line item" do
        before(:each) do
          stub.proxy(LineItem).new
          @shopping_cart = ShoppingCart.new(attrs)
        end

        it "creates a @line_items collection with one line item" do
          @shopping_cart.invoices.should have(1).invoice
          @shopping_cart.invoices.first.should be_a LineItem
        end

        it "creates a new line item object for the line item in the attribute hash" do
          invoice = attrs[:line_item_invoice_list][:order_line_item_invoice]
          LineItem.should have_received.new(invoice)
        end
      end

      context "with two invoice line items" do
        before(:each) do
          @invoices = attrs[:line_item_invoice_list][:order_line_item_invoice] = [
            {:line_item_type => "SalesTax", :unit_price => "0.0000"},
            {:line_item_type => "Shipping", :unit_price => "0.0000"}
          ]
          stub.proxy(LineItem).new
          @shopping_cart = ShoppingCart.new(attrs)
        end

        it "creates a @line_items collection with two line items" do
          @shopping_cart.invoices.should have(2).invoices
          @shopping_cart.invoices.each do |invoice|
            invoice.should be_a LineItem
          end
        end

        it "creates a new line item object for each line item in the attribute hash" do
          @invoices.each do |invoice|
            LineItem.should have_received.new(invoice)
          end
        end
      end

      context "with one promo line item" do
        before(:each) do
          stub.proxy(LineItem).new
          @shopping_cart = ShoppingCart.new(attrs)
        end

        it "creates a @line_items collection with one line item" do
          @shopping_cart.promos.should have(1).promo
          @shopping_cart.promos.first.should be_a LineItem
        end

        it "creates a new line item object for the line item in the attribute hash" do
          promo = attrs[:line_item_promo_list][:order_line_item_promo]
          LineItem.should have_received.new(promo)
        end
      end

      context "with two promo line items" do
        before(:each) do
          @promos = attrs[:line_item_promo_list][:order_line_item_promo] = [
            {:line_item_type => "Promotion", :unit_price => "0.0000", :promo_code => nil},
            {:line_item_type => "AdditionalCostOrDiscount", :unit_price => "1.9900", :promo_code => nil}
          ]
          stub.proxy(LineItem).new
          @shopping_cart = ShoppingCart.new(attrs)
        end

        it "creates a @line_items collection with two line items" do
          @shopping_cart.promos.should have(2).promos
          @shopping_cart.promos.each do |promo|
            promo.should be_a LineItem
          end
        end

        it "creates a new line item object for each line item in the attribute hash" do
          @promos.each do |promo|
            LineItem.should have_received.new(promo)
          end
        end
      end
    end
  end
end