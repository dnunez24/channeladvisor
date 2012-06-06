module ChannelAdvisor
  class ShoppingCart < Base
    attr_accessor :id, :checkout_source, :vat_tax_calculation_option, :vat_shipping_option,
      :vat_gift_wrap_option, :items, :invoices, :promos

    def initialize(attrs={})
      @id                         = attrs[:cart_id]
      @checkout_source            = attrs[:checkout_source]
      @vat_tax_calculation_option = attrs[:vat_tax_calculation_option]
      @vat_shipping_option        = attrs[:vat_shipping_option]
      @vat_gift_wrap_option       = attrs[:vat_gift_wrap_option]

      if items = attrs[:line_item_sku_list]
        @items = arrayify(items[:order_line_item_item]).map { |l| LineItem.new(l) } 
      end

      if invoices = attrs[:line_item_invoice_list]
        @invoices = arrayify(invoices[:order_line_item_invoice]).map { |i| LineItem.new(i) }  
      end
      
      if promos = attrs[:line_item_promo_list]
        @promos = arrayify(promos[:order_line_item_promo]).map { |p| LineItem.new(p) }
      end
    end
  end
end