module ChannelAdvisor
  class LineItem
    attr_accessor :id, :type, :sku, :title, :unit_price, :quantity, :allow_negative_quantity, :sale_source, :buyer_user_id,
      :buyer_feedback_rating, :sales_source_id, :vat_rate, :tax_cost, :shipping_cost, :shipping_tax_cost, :gift_wrap_cost,
      :gift_wrap_tax_cost, :gift_message, :gift_wrap_level, :recycling_fee, :unit_weight, :unit_of_measure, :warehouse_location,
      :user_name, :distribution_center, :is_fba, :promo_code

    def initialize(attrs={})
      unless attrs.nil?
        @id = attrs[:line_item_id]
        @type = attrs[:line_item_type]
        @sku = attrs[:sku]
        @title = attrs[:title]
        @unit_price = attrs[:unit_price].to_f
        @quantity = attrs[:quantity].to_i
        @allow_negative_quantity = attrs[:allow_negative_quantity]
        @sale_source = attrs[:sale_source]
        @buyer_user_id = attrs[:buyer_user_id]
        @buyer_feedback_rating = attrs[:buyer_feedback_rating]
        @sales_source_id = attrs[:sales_source_id]
        @vat_rate = attrs[:vat_rate].to_f
        @tax_cost = attrs[:tax_cost].to_f
        @shipping_cost = attrs[:shipping_cost].to_f
        @shipping_tax_cost = attrs[:shipping_tax_cost].to_f
        @gift_wrap_cost = attrs[:gift_wrap_cost].to_f
        @gift_wrap_tax_cost = attrs[:gift_wrap_tax_cost].to_f
        @gift_message = attrs[:gift_message]
        @gift_wrap_level = attrs[:gift_wrap_level]
        @recycling_fee = attrs[:recycling_fee].to_f
        @unit_weight = attrs[:unit_weight].to_f
        @unit_of_measure = attrs[:unit_of_measure]
        @warehouse_location = attrs[:warehouse_location]
        @user_name = attrs[:user_name]
        @distribution_center = attrs[:distribution_center_code]
        @is_fba = attrs[:is_fba]
        @promo_code = attrs[:promo_code]
      end
    end # initialize
  end # LineItem
end # ChannelAdvisor
