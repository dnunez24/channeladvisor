module ChannelAdvisor
  module Services
    class OrderService < BaseService
      WSDL = "https://api.channeladvisor.com/ChannelAdvisorAPI/v6/OrderService.asmx?WSDL"
      
      NAMESPACES = {
        "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
        "xmlns:web" => "http://api.channeladvisor.com/webservices/",
        "xmlns:ord" => "http://api.channeladvisor.com/datacontracts/orders"
      }

      # Check authorization for and availability of the order service
      #
      # @return [HTTPI::Response] HTTP response object containing the SOAP XML response
      def ping
        soap_response = client.request :ping do
          soap.xml do |xml|
            xml.soap :Envelope, NAMESPACES do |envelope|
              soap_header(envelope)
              envelope.soap :Body do |body|
                body.web :Ping
              end
            end
          end
        end     

        @last_request = client.http
        @last_response = soap_response.http
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
        soap_response = client.request :get_order_list do
          soap.xml do |root|
            root.soap :Envelope, NAMESPACES do |envelope|
              soap_header(envelope)
              envelope.soap :Body do |body|
                body.web :GetOrderList do |get_order_list|
                  get_order_list.web :accountID, config(:account_id)
                  get_order_list.web :orderCriteria do |order_criteria|
                    order_criteria.ord :OrderCreationFilterBeginTimeGMT, xsi_nil(criteria[:created_from])
                    order_criteria.ord :OrderCreationFilterEndTimeGMT, xsi_nil(criteria[:created_to])
                    order_criteria.ord :StatusUpdateFilterBeginTimeGMT, xsi_nil(criteria[:updated_from])
                    order_criteria.ord :StatusUpdateFilterEndTimeGMT, xsi_nil(criteria[:updated_to])
                    order_criteria.ord :JoinDateFiltersWithOr, xsi_nil(criteria[:join_dates])


                    if criteria[:detail_level]
                      order_criteria.ord :DetailLevel, criteria[:detail_level]
                    end

                    if criteria[:export_state]
                      order_criteria.ord :ExportState, criteria[:export_state]
                    end

                    if criteria[:order_ids]
                      order_criteria.ord :OrderIDList do |order_id_list|
                        build_id_list(order_id_list, criteria[:order_ids])
                      end
                    end

                    if criteria[:client_order_ids]
                      order_criteria.ord :ClientOrderIdentifierList do |client_order_identifier_list|
                        build_id_list(client_order_identifier_list, criteria[:client_order_ids])
                      end
                    end

                    if criteria[:state]
                      order_criteria.ord :OrderStateFilter, criteria[:state]
                    end

                    if criteria[:payment_status]
                      order_criteria.ord :PaymentStatusFilter, criteria[:payment_status]
                    end

                    if criteria[:checkout_status]
                      order_criteria.ord :CheckoutStatusFilter, criteria[:checkout_status]
                    end

                    if criteria[:shipping_status]
                      order_criteria.ord :ShippingStatusFilter, criteria[:shipping_status]
                    end

                    if criteria[:refund_status]
                      order_criteria.ord :RefundStatusFilter, criteria[:refund_status]
                    end

                    if criteria[:distribution_center]
                      order_criteria.ord :DistributionCenterCode, criteria[:distribution_center]
                    end

                    order_criteria.ord :PageNumberFilter, xsi_nil(criteria[:page_number])
                    order_criteria.ord :PageSize, xsi_nil(criteria[:page_size])
                  end
                end
              end
            end
          end
        end

        @last_request = client.http
        @last_response = soap_response.http
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
          soap.xml do |root|
            root.soap :Envelope, NAMESPACES do |envelope|
              soap_header(envelope)
              envelope.soap :Body do |body|
                body.web :SetOrdersExportStatus do |set_orders_export_status|
                  set_orders_export_status.web :accountID, config(:account_id)
                  set_orders_export_status.web :clientOrderIdentifiers do |client_order_identifiers|
                    client_order_ids.each do |client_order_id|
                      client_order_identifiers.web :string, client_order_id
                    end
                  end
                  set_orders_export_status.web :markAsExported, mark_as_exported
                end
              end
            end
          end
        end
        @last_request = client.http
        @last_response = soap_response.http
      end # set_orders_export_status

    private

      def build_id_list(parent, list)
        unless list.nil?
          type = case list.first
            when Integer then :int
            when String then :string
          end
          list.each { |id| parent.ord type, id }
        end
      end # build_id_list
    end # OrderService
  end # Services
end # ChannelAdvisor