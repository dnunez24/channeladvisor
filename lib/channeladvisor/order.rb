module ChannelAdvisor
  class Order
    WSDL = "https://api.channeladvisor.com/ChannelAdvisorAPI/v6/OrderService.asmx?WSDL"

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
                xml.web :DeveloperKey, config(:developer_key)
                xml.web :Password, config(:password)
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
        soap.xml do |root|
          root.soap :Envelope, Order::NAMESPACES do |envelope|
            envelope.soap :Header do |header|
              header.web :APICredentials do |api_credentials|
                api_credentials.web :DeveloperKey, config(:developer_key)
                api_credentials.web :Password, config(:password)
              end
            end
            envelope.soap :Body do |body|
              body.web :GetOrderList do |get_order_list|
                get_order_list.web :accountID, config(:account_id)
                get_order_list.web :orderCriteria do |order_criteria|
                  order_criteria.ord :OrderCreationFilterBeginTimeGMT, xsi_nil(filters[:created_from])
                  order_criteria.ord :OrderCreationFilterEndTimeGMT, xsi_nil(filters[:created_to])
                  order_criteria.ord :StatusUpdateFilterBeginTimeGMT, xsi_nil(filters[:updated_from])
                  order_criteria.ord :StatusUpdateFilterEndTimeGMT, xsi_nil(filters[:updated_to])
                  order_criteria.ord :JoinDateFiltersWithOr, xsi_nil(filters[:join_dates])
                  order_criteria.ord :DetailLevel, xsi_nil(filters[:detail_level])
                  order_criteria.ord :ExportState, xsi_nil(filters[:export_state])
                  order_criteria.ord :OrderIDList do |order_id_list|
                    build_id_list(order_id_list, filters[:order_ids])
                  end
                  order_criteria.ord :ClientOrderIdentifierList do |client_order_identifier_list|
                    build_id_list(client_order_identifier_list, filters[:client_order_ids])
                  end
                  order_criteria.ord :OrderStateFilter, xsi_nil(filters[:state])
                  order_criteria.ord :PaymentStatusFilter, xsi_nil(filters[:payment_status])
                  order_criteria.ord :CheckoutStatusFilter, xsi_nil(filters[:checkout_status])
                  order_criteria.ord :ShippingStatusFilter, xsi_nil(filters[:shipping_status])
                  order_criteria.ord :RefundStatusFilter, xsi_nil(filters[:refund_status])
                  order_criteria.ord :DistributionCenterCode, xsi_nil(filters[:distribution_center])
                  order_criteria.ord :PageNumberFilter, xsi_nil(filters[:page_number])
                  order_criteria.ord :PageSize, xsi_nil(filters[:page_size])
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
        order.items = order_node.xpath('./ord:ShoppingCart/ord:LineItemSKUList/ord:OrderLineItemItem', ns_ord)
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
      @client ||= Client.new WSDL
    end

    def self.config(attribute)
      ChannelAdvisor.configuration.send(attribute.to_sym)
    end

    def self.xsi_nil(filter)
      filter.nil? ? {"xsi:nil" => true} : filter
    end

    def self.build_id_list(parent, list)
      unless list.nil?
        type = case list.first
          when Integer then :int
          when String then :string
        end
        list.each { |id| parent.ord type, id }
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
