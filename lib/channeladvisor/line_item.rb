module ChannelAdvisor
  class LineItem < Base
    attr_accessor :id, :type, :sku, :title, :unit_price, :quantity, :allow_negative_quantity, :sale_source, :buyer_user_id,
      :buyer_feedback_rating, :sales_source_id, :vat_rate, :tax_cost, :shipping_cost, :shipping_tax_cost, :gift_wrap_cost,
      :gift_wrap_tax_cost, :gift_message, :gift_wrap_level, :recycling_fee, :unit_weight, :unit_of_measure, :warehouse_location,
      :user_name, :distribution_center, :is_fba, :promo_code, :shipping_price, :line_promos

    def initialize(attrs={})
      @id                       = attrs[:line_item_id]
      @type                     = attrs[:line_item_type]
      @sku                      = attrs[:sku]
      @title                    = attrs[:title]
      @unit_price               = attrs[:unit_price].to_f
      @quantity                 = attrs[:quantity].to_i
      @allow_negative_quantity  = attrs[:allow_negative_quantity]
      @sale_source              = attrs[:item_sale_source]
      @buyer_user_id            = attrs[:buyer_user_id]
      @buyer_feedback_rating    = attrs[:buyer_feedback_rating]
      @sales_source_id          = attrs[:sales_source_id]
      @vat_rate                 = attrs[:vat_rate].to_f
      @tax_cost                 = attrs[:tax_cost].to_f
      @shipping_cost            = attrs[:shipping_cost].to_f
      @shipping_tax_cost        = attrs[:shipping_tax_cost].to_f
      @gift_wrap_cost           = attrs[:gift_wrap_cost].to_f
      @gift_wrap_tax_cost       = attrs[:gift_wrap_tax_cost].to_f
      @gift_message             = attrs[:gift_message]
      @gift_wrap_level          = attrs[:gift_wrap_level]
      @recycling_fee            = attrs[:recycling_fee].to_f
      @unit_weight              = attrs[:unit_weight].to_f
      @unit_of_measure          = attrs[:unit_of_measure]
      @warehouse_location       = attrs[:warehouse_location]
      @user_name                = attrs[:user_name]
      @distribution_center      = attrs[:distribution_center_code]
      @is_fba                   = attrs[:is_fba]
      @promo_code               = attrs[:promo_code]
      @shipping_price           = attrs[:shipping_price].to_f

      if line_promos = attrs[:item_promo_list]
        @line_promos = arrayify(line_promos[:order_line_item_item_promo]).map { |p| LineItem.new(p) }
      end      
    end # initialize
  end # LineItem
end # ChannelAdvisor
