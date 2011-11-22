module ChannelAdvisor
  class Order
    NAMESPACES = {
      "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
      "xmlns:web" => "http://api.channeladvisor.com/webservices/",
      "xmlns:ord" => "http://api.channeladvisor.com/datacontracts/orders"
    }

    def initialize(attributes = {})
      assign_attributes(attributes)
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

      result_data = response.body[:get_order_list_response][:get_order_list_result][:result_data]
      return result_data if result_data.nil?

      orders = []

      [result_data[:order_response_item]].flatten.each do |params|
        orders << Order.new(params)
      end

      return orders
    end

    private

    def self.client
      Connection.client "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx?WSDL"
    end

    def assign_attributes(attributes)
      attributes.each do |key, value|
        if value.is_a? Hash
          assign_attributes(value)
        else
          if key.to_s =~ /^\w*$/
            self.class.instance_eval "attr_accessor :#{key}"
            self.__send__("#{key}=", value)
          end
        end
      end
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
        end
      end
    end
  end
end
