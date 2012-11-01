module ChannelAdvisor
  class LineItemPromo
    attr_accessor :line_item_type, :unit_price, :promo_code, :shipping_price
    def initialize(attrs={})
      @line_item_type = attrs[:line_item_type]
      @unit_price     = attrs[:unit_price].to_f
      @promo_code     = attrs[:promo_code]
      @shipping_price = attrs[:shipping_price].to_f
    end
  end
end