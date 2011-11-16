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
      attributes.each do |key, value|
        if key.to_s =~ /^\w*$/
          self.class.__send__ :attr_accessor, key
          self.__send__("#{key}=", value)
        end
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

      status = response.xpath("//xmlns:Status").text
      message = response.xpath("//xmlns:ResultData").text

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
    # @return [Array<Order>] Array of {Order} objects
    # @raise [NoResultError] Raises an exception when no results are returned
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
                  build_filter xml, :OrderCreationFilterBeginTimeGMT, filters[:created_from]
                  build_filter xml, :OrderCreationFilterEndTimeGMT, filters[:created_to]
                  build_filter xml, :StatusUpdateFilterBeginTimeGMT, filters[:updated_from]
                  build_filter xml, :StatusUpdateFilterEndTimeGMT, filters[:updated_to]
                  build_filter xml, :JoinDateFiltersWithOr, filters[:join_dates]
                  build_filter xml, :DetailLevel, filters[:detail_level]
                  build_filter xml, :ExportState, filters[:export_state]
                  build_filter xml, :OrderIDList, filters[:order_ids]
                  build_filter xml, :ClientOrderIdentifierList, filters[:client_order_ids]
                  build_filter xml, :OrderStateFilter, filters[:state]
                  build_filter xml, :PaymentStatusFilter, filters[:payment_status]
                  build_filter xml, :CheckoutStatusFilter, filters[:checkout_status]
                  build_filter xml, :ShippingStatusFilter, filters[:shipping_status]
                  build_filter xml, :RefundStatusFilter, filters[:refund_status]
                  build_filter xml, :DistributionCenterCode, filters[:distribution_center]
                  build_filter xml, :PageNumberFilter, filters[:page_number]
                  build_filter xml, :PageSize, filters[:page_size]
                end
              end
            end
          end
        end
      end

      result_data = response.body[:get_order_list_response][:get_order_list_result][:result_data]

      if result_data.nil?
        raise NoResultError, "No order data returned in the response"
      else
        orders = []

        [result_data[:order_response_item]].flatten.each do |params|
          orders << Order.new(params)
        end

        return orders
      end
    end

    private

    def self.client
      Connection.client "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx?WSDL"
    end

    def self.build_filter(parent, element, filter)
      if filter.nil?
      	case element
      	when :OrderIDList, :ClientOrderIdentifierList, :DistributionCenterCode
      		nil
      	else
      		parent.ord element, nil, "xsi:nil" => true
      	end
      else
        parent.ord element, filter
      end
    end
  end
end
