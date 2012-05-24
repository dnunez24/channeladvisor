module ChannelAdvisor
  class LineItem
    attr_reader(
      :id,
      :type,
      :sku,
      :title,
      :unit_price,
      :quantity,
      :allow_negative_quantity,
      :sale_source,
      :buyer_user_id,
      :buyer_feedback_rating,
      :sales_source_id,
      :vat_rate,
      :tax_cost,
      :shipping_cost,
      :shipping_tax_cost,
      :gift_wrap_cost,
      :gift_wrap_tax_cost,
      :gift_message,
      :gift_wrap_level,
      :recycling_fee,
      :unit_weight,
      :unit_of_measure,
      :warehouse_location,
      :user_name,
      :distribution_center,
      :is_fba
    )

    def initialize(item)
      ns = {'ord' => NAMESPACES['xmlns:ord']}
      @id                       = item.xpath('./ord:LineItemID', ns).text
      @type                     = item.xpath('./ord:LineItemType', ns).text
      @sku                      = item.xpath('./ord:SKU', ns).text
      @title                    = item.xpath('./ord:Title', ns).text
      @unit_price               = item.xpath('./ord:UnitPrice', ns).text
      @quantity                 = item.xpath('./ord:Quantity', ns).text
      @allow_negative_quantity  = item.xpath('./ord:AllowNegativeQuantity', ns).text
      @sale_source              = item.xpath('./ord:ItemSaleSource', ns).text
      @buyer_user_id            = item.xpath('./ord:BuyerUserID', ns).text
      @buyer_feedback_rating    = item.xpath('./ord:BuyerFeedbackRating', ns).text
      @sales_source_id          = item.xpath('./ord:SalesSourceID', ns).text
      @vat_rate                 = item.xpath('./ord:VATRate', ns).text
      @tax_cost                 = item.xpath('./ord:TaxCost', ns).text
      @shipping_cost            = item.xpath('./ord:ShippingCost', ns).text
      @shipping_tax_cost        = item.xpath('./ord:ShippingTaxCost', ns).text
      @gift_wrap_cost           = item.xpath('./ord:GiftWrapCost', ns).text
      @gift_wrap_tax_cost       = item.xpath('./ord:GiftWrapTaxCost', ns).text
      @gift_message             = item.xpath('./ord:GiftMessage', ns).text
      @gift_wrap_level          = item.xpath('./ord:GiftWrapLevel', ns).text
      @recycling_fee            = item.xpath('./ord:RecyclingFee', ns).text
      @unit_weight              = item.xpath('./ord:UnitWeight', ns).text
      @unit_of_measure          = item.xpath('./ord:UnitWeight', ns).attribute('UnitOfMeasure').text
      @warehouse_location       = item.xpath('./ord:WarehouseLocation', ns).text
      @user_name                = item.xpath('./ord:UserName', ns).text
      @distribution_center      = item.xpath('./ord:DistributionCenterCode', ns).text
      @is_fba                   = item.xpath('./ord:IsFBA', ns).text
    end # initialize
  end # LineItem
end # ChannelAdvisor
