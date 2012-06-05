module ChannelAdvisor
  module Services
    class OrderService < BaseService
      document "http://api.channeladvisor.com/ChannelAdvisorAPI/v6/OrderService.asmx?WSDL"

      class << self
        # Check authorization for and availability of the order service
        #
        # @return [HTTPI::Response] HTTP response object containing the SOAP XML response
        def ping
          soap_response = client.request :ping do
            soap.header = soap_header
          end

          @last_request = client.http
          @last_response = soap_response
        end # ping

        # Retrieve a list of orders filtered by order criteria
        #
        # @example List orders created between 11/11/2011 and 11/15/2011
        #   order_service.get_order_list(:created_from => DateTime.new(2011,11,11), :created_to => DateTime.new(2011,11,15))
        #
        # @example List orders with an order ID in the given list
        #   order_service.get_order_list(:order_ids => [12345, 67890])
        #
        # @param [optional, Hash] criteria Criteria used to filter the order list
        # @option criteria [DateTime] :created_from Order creation start time in GMT/UTC
        # @option criteria [DateTime] :created_to Order creation end time in GMT/UTC
        # @option criteria [DateTime] :updated_from Order update start time in GMT/UTC
        # @option criteria [DateTime] :updated_to Order update end time in GMT/UTC
        # @option criteria [Boolean] :join_dates `true` indicates that orders satisfy both
        #   the created date range and the updated date range
        # @option criteria [String] :detail_level `Low`, `Medium`, `High` or `Complete`
        # @option criteria [String] :export_state `Unknown`, `NotExported` or `Exported`
        # @option criteria [Array<Integer>] :order_ids List of order IDs
        # @option criteria [Array<String>] :client_order_ids List of client order IDs
        # @option criteria [String] :state `Active`, `Archived`, or `Cancelled`
        # @option criteria [String] :payment_status `NoChange`, `NotSubmitted`, `Cleared`, `Submitted`, `Failed`, or `Deposited`
        # @option criteria [String] :checkout_status `NoChange`, `NotVisited`, `Completed`, `Visited`, `Cancelled`, `CompletedOffline`, or `OnHold`
        # @option criteria [String] :shipping_status `NoChange`, `Unshipped`, `PendingShipment`, `PartiallyShipped`, or `Shipped`
        # @option criteria [String] :refund_status `NoRefunds`, `OrderLevel`, `LineItemLevel`, `OrderAndLineItemLevel`, or `FailedAttemptsOnly`
        # @option criteria [String] :distribution_center Only orders containing at least one item from the specified distribution center
        # @option criteria [Integer] :page_number Page number of result set
        # @option criteria [Integer] :page_size Size of each page in result set
        #
        # @return [HTTPI::Response] HTTP response object containing the SOAP XML response
        def get_order_list(criteria = {})
          order_criteria = {}
          order_criteria["ins1:OrderCreationFilterBeginTimeGMT"] = criteria[:created_from]
          order_criteria["ins1:OrderCreationFilterEndTimeGMT"]   = criteria[:created_to]
          order_criteria["ins1:StatusUpdateFilterBeginTimeGMT"]  = criteria[:updated_from]
          order_criteria["ins1:StatusUpdateFilterEndTimeGMT"]    = criteria[:updated_to]
          order_criteria["ins1:JoinDateFiltersWithOr"]           = criteria[:join_dates]

          if order_ids = criteria[:order_ids]
            order_criteria["ins1:OrderIDList"] = {"ins1:int" => order_ids}
          end

          if client_order_ids = criteria[:client_order_ids]
            order_criteria["ins1:ClientOrderIdentifierList"] = {"ins1:string" => client_order_ids}
          end

          order_criteria["ins1:DetailLevel"]                     = criteria[:detail_level]        if criteria[:detail_level]
          order_criteria["ins1:ExportState"]                     = criteria[:export_state]        if criteria[:export_state]
          order_criteria["ins1:OrderStateFilter"]                = criteria[:state]               if criteria[:state]
          order_criteria["ins1:PaymentStatusFilter"]             = criteria[:payment_status]      if criteria[:payment_status]
          order_criteria["ins1:CheckoutStatusFilter"]            = criteria[:checkout_status]     if criteria[:checkout_status]
          order_criteria["ins1:ShippingStatusFilter"]            = criteria[:shipping_status]     if criteria[:shipping_status]
          order_criteria["ins1:RefundStatusFilter"]              = criteria[:refund_status]       if criteria[:refund_status]
          order_criteria["ins1:DistributionCenterCode"]          = criteria[:distribution_center] if criteria[:distribution_center]
          order_criteria["ins1:PageNumberFilter"]                = criteria[:page_number]
          order_criteria["ins1:PageSize"]                        = criteria[:page_size]

          soap_response = client.request :get_order_list do
            soap.header = soap_header
            soap.body = {
              "ins0:accountID" => config(:account_id),
              "ins0:orderCriteria" => order_criteria
            }
          end

          @last_request = client.http
          @last_response = soap_response
        end # get_order_list

        # Set the export status for a list of orders
        #
        # @example Mark orders as exported
        #   order_service.set_orders_export_status(['ABCD1234', 'EFGH5678'], true)
        # 
        # @example Mark orders as not exported
        #   order_service.set_orders_export_status(['ABCD1234', 'EFGH5678'], false)
        #
        # @param [Array] client_order_ids List of client order identifiers
        # @param [Boolean] mark_as_exported Set the order to exported (`true`) or not exported (`false`)
        #
        # @return [HTTPI::Response] HTTP response object containing the SOAP XML response
        def set_orders_export_status(client_order_ids, mark_as_exported)
          soap_response = client.request :set_orders_export_status do
            soap.header = soap_header
            soap.body = {
              "ins0:accountID" => config(:account_id),
              "ins0:clientOrderIdentifiers" => {
                "ins0:string" => client_order_ids
              },
              "ins0:markAsExported" => mark_as_exported
            }
          end

          @last_request = client.http
          @last_response = soap_response
        end # set_orders_export_status
      end
    end # OrderService
  end # Services
end # ChannelAdvisor