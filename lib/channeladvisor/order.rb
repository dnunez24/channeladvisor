module ChannelAdvisor
  class Order
    NAMESPACES = {
      "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
      "xmlns:web" => "http://api.channeladvisor.com/webservices/",
      "xmlns:ord" => "http://api.channeladvisor.com/datacontracts/orders"
    }

    attr_accessor(
      :id,
      :client_order_id,
      :seller_order_id,
      :state,
      :created_at,
      :updated_at,
      :checkout_status,
      :checkout_date,
      :payment_status,
      :payment_date,
      :shipping_status,
      :shipping_date,
      :refund_status,
      :total,
      :cancelled_at,
      :flag_style,
      :flag_description,
      :reseller_id,
      :buyer_email,
      :email_opt_in
    )
    attr_reader :items

    def items=(items)
      @items = []
      items.each do |item|
        @items << Order::LineItem.new(item)
      end
    end

    # Checks authorization for and availability of the order service
    #
    # @raise [ServiceFailure] Raises an exception when the service returns a failure status
    # @return [String] Status message
    def self.ping
      response = client.request :ping do
        soap.xml do |xml|
          xml.soap :Envelope, Order::NAMESPACES do
            xml.soap :Header do
              xml.web :APICredentials do
                xml.web :DeveloperKey, ChannelAdvisor.developer_key
                xml.web :Password, ChannelAdvisor.password
              end
            end
            xml.soap :Body do
              xml.web :Ping
            end
          end
        end
      end

      status = response.xpath('//web:Status', 'web' => 'http://api.channeladvisor.com/webservices/').text
      message = response.xpath('//web:ResultData', 'web' => 'http://api.channeladvisor.com/webservices/').text

      if status == "Failure"
        raise ServiceFailure, message
      else
        message
      end
    end

    # Lists all orders restricted by the provided filters
    #
    # @example List orders created between 11/11/2011 and 11/15/2011
    # 	ChannelAdvisor::Order.list(:created_from => DateTime.new(2011,11,11), :created_to => DateTime.new(2011,11,15))
    #
    # @param [optional, Hash] filters Criteria used to filter the order list
    # @option filters [DateTime] :created_from Order creation start time in GMT/UTC
    # @option filters [DateTime] :created_to Order creation end time in GMT/UTC
    # @option filters [DateTime] :updated_from Order update start time in GMT/UTC
    # @option filters [DateTime] :updated_to Order update end time in GMT/UTC
    # @option filters [Boolean] :join_dates `true` indicates that orders can satisfy either
    # 	the created date range or the updated date range
    # @option filters [String] :detail_level `Low`, `Medium`, `High` or `Complete`
    # @option filters [String] :export_state `Unknown`, `NotExported` or `Exported`
    # @option filters [Array<Integer>] :order_ids Array of order IDs
    # @option filters [Array<String>] :client_order_ids Array of client order IDs
    # @option filters [String] :state `Active`, `Archived`, or `Cancelled`
    # @option filters [String] :payment_status `NoChange`, `NotSubmitted`, `Cleared`, `Submitted`, `Failed`, or `Deposited`
    # @option filters [String] :checkout_status `NoChange`, `NotVisited`, `Completed`, `Visited`, `Cancelled`, `CompletedOffline`, or `OnHold`
    # @option filters [String] :shipping_status `NoChange`, `Unshipped`, `PendingShipment`, `PartiallyShipped`, or `Shipped`
    # @option filters [String] :refund_status `NoRefunds`, `OrderLevel`, `LineItemLevel`, `OrderAndLineItemLevel`, or `FailedAttemptsOnly`
    # @option filters [String] :distribution_center Only orders containing at least one item from the specified distribution center
    # @option filters [Integer] :page_number Page number of result set
    # @option filters [Integer] :page_size Size of each page in result set
    #
    # @return [Array<Order>, nil] Array of {Order} objects or nil
    def self.list(filters = {})
      response = client.request :get_order_list do
        soap.xml do |xml|
          xml.soap :Envelope, Order::NAMESPACES do
            xml.soap :Header do
              xml.web :APICredentials do
                xml.web :DeveloperKey, ChannelAdvisor.developer_key
                xml.web :Password, ChannelAdvisor.password
              end
            end
            xml.soap :Body do
              xml.web :GetOrderList do
                xml.web :accountID, ChannelAdvisor.account_id
                xml.web :orderCriteria do
                  nillable xml, :OrderCreationFilterBeginTimeGMT, filters[:created_from]
                  nillable xml, :OrderCreationFilterEndTimeGMT, filters[:created_to]
                  nillable xml, :StatusUpdateFilterBeginTimeGMT, filters[:updated_from]
                  nillable xml, :StatusUpdateFilterEndTimeGMT, filters[:updated_to]
                  nillable xml, :JoinDateFiltersWithOr, filters[:join_dates]
                  nillable xml, :DetailLevel, filters[:detail_level]
                  nillable xml, :ExportState, filters[:export_state]
                  optional xml, :OrderIDList, filters[:order_ids]
                  optional xml, :ClientOrderIdentifierList, filters[:client_order_ids]
                  nillable xml, :OrderStateFilter, filters[:state]
                  nillable xml, :PaymentStatusFilter, filters[:payment_status]
                  nillable xml, :CheckoutStatusFilter, filters[:checkout_status]
                  nillable xml, :ShippingStatusFilter, filters[:shipping_status]
                  nillable xml, :RefundStatusFilter, filters[:refund_status]
                  optional xml, :DistributionCenterCode, filters[:distribution_center]
                  nillable xml, :PageNumberFilter, filters[:page_number]
                  nillable xml, :PageSize, filters[:page_size]
                end
              end
            end
          end
        end
      end

      orders = []
      ns_web = {'web' => NAMESPACES['xmlns:web']}
      ns_ord = {'ord' => NAMESPACES['xmlns:ord']}
      order_nodes = response.xpath('//web:OrderResponseItem', ns_web)
      return orders if order_nodes.empty?

      order_nodes.each do |order_node|
        order = Order.new
        order.id = order_node.xpath('./ord:OrderID', ns_ord).text
        order.client_order_id = order_node.xpath('./ord:ClientOrderIdentifier', ns_ord).text
        order.state = order_node.xpath('./ord:OrderState', ns_ord).text
        order.created_at = DateTime.parse(order_node.xpath('./ord:OrderTimeGMT', ns_ord).text + " UTC")
        order.updated_at = DateTime.parse(order_node.xpath('./ord:LastUpdateDate', ns_ord).text + " UTC")
        order.checkout_status = order_node.xpath('./ord:OrderStatus/ord:CheckoutStatus', ns_ord).text
        order.payment_status = order_node.xpath('./ord:OrderStatus/ord:PaymentStatus', ns_ord).text
        order.shipping_status = order_node.xpath('./ord:OrderStatus/ord:ShippingStatus', ns_ord).text
        order.refund_status = order_node.xpath('./ord:OrderStatus/ord:OrderRefundStatus', ns_ord).text
        items = order_node.xpath('./ord:ShoppingCart/ord:LineItemSKUList/ord:OrderLineItemItem', ns_ord)
        order.items = items
        orders << order
      end

      return orders
    rescue Savon::HTTP::Error => error
      raise HttpError, error.to_s unless error.to_hash[:code] == 500
    rescue Savon::SOAP::Fault => fault
      raise SoapFault, fault.to_s
    end

    private

    def self.client
      Connection.client "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx?WSDL"
    end

    def self.nillable(xml, element, filter)
      if filter.nil?
        xml.ord element, nil, "xsi:nil" => true
      else
        xml.ord element, filter
      end
    end

    def self.optional(xml, element, filter)
      if filter.nil?
      	nil
      else
        case element
        when :OrderIDList
          xml.ord element do
            filter.each { |item| xml.ord(:int, item) }
          end
        when :ClientOrderIdentifierList
          xml.ord element do
            filter.each { |item| xml.ord(:string, item) }
          end
        else
          xml.ord(element, filter)
        end
      end
    end

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
        ns = {'ord' => Order::NAMESPACES['xmlns:ord']}
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
      end
    end
  end
end
