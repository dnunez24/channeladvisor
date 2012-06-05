module ChannelAdvisor
  class ShoppingCart < Base
    attr_accessor :id, :checkout_source, :vat_tax_calculation_option, :vat_shipping_option,
      :vat_gift_wrap_option, :items, :invoices, :promos

    def initialize(attrs={})
      unless attrs.nil?
        @id                         = attrs[:cart_id]
        @checkout_source            = attrs[:checkout_source]
        @vat_tax_calculation_option = attrs[:vat_tax_calculation_option]
        @vat_shipping_option        = attrs[:vat_shipping_option]
        @vat_gift_wrap_option       = attrs[:vat_gift_wrap_option]
        @items                      = arrayify(attrs[:line_item_sku_list][:order_line_item_item]).map { |l| LineItem.new(l) } 
        @invoices                   = arrayify(attrs[:line_item_invoice_list][:order_line_item_invoice]).map { |i| LineItem.new(i) }
        @promos                     = arrayify(attrs[:line_item_promo_list][:order_line_item_promo]).map { |p| LineItem.new(p) }
      end
    end
  end
end