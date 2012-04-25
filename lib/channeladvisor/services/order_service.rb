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

      # Checks authorization for and availability of the order service
      #
      # @raise [ServiceFailure] Raises an exception when the service returns a failure status
      # @return [String] Status message
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

        # TODO: Handle Savon::SOAP::Response faults and HTTP errors

        @last_request = client.http
        @last_response = soap_response.http
      end # ping

      def get_order_list(filters = {})
        soap_response = client.request :get_order_list do
          soap.xml do |root|
            root.soap :Envelope, NAMESPACES do |envelope|
              soap_header(envelope)
              envelope.soap :Body do |body|
                body.web :GetOrderList do |get_order_list|
                  get_order_list.web :accountID, config(:account_id)
                  get_order_list.web :orderCriteria do |order_criteria|
                    order_criteria.ord :OrderCreationFilterBeginTimeGMT, xsi_nil(filters[:created_from])
                    order_criteria.ord :OrderCreationFilterEndTimeGMT, xsi_nil(filters[:created_to])
                    order_criteria.ord :StatusUpdateFilterBeginTimeGMT, xsi_nil(filters[:updated_from])
                    order_criteria.ord :StatusUpdateFilterEndTimeGMT, xsi_nil(filters[:updated_to])
                    order_criteria.ord :JoinDateFiltersWithOr, xsi_nil(filters[:join_dates])


                    if filters[:detail_level]
                      order_criteria.ord :DetailLevel, filters[:detail_level]
                    end

                    if filters[:export_state]
                      order_criteria.ord :ExportState, filters[:export_state]
                    end

                    if filters[:order_ids]
                      order_criteria.ord :OrderIDList do |order_id_list|
                        build_id_list(order_id_list, filters[:order_ids])
                      end
                    end

                    if filters[:client_order_ids]
                      order_criteria.ord :ClientOrderIdentifierList do |client_order_identifier_list|
                        build_id_list(client_order_identifier_list, filters[:client_order_ids])
                      end
                    end

                    if filters[:state]
                      order_criteria.ord :OrderStateFilter, filters[:state]
                    end

                    if filters[:payment_status]
                      order_criteria.ord :PaymentStatusFilter, filters[:payment_status]
                    end

                    if filters[:checkout_status]
                      order_criteria.ord :CheckoutStatusFilter, filters[:checkout_status]
                    end

                    if filters[:shipping_status]
                      order_criteria.ord :ShippingStatusFilter, filters[:shipping_status]
                    end

                    if filters[:refund_status]
                      order_criteria.ord :RefundStatusFilter, filters[:refund_status]
                    end

                    if filters[:distribution_center]
                      order_criteria.ord :DistributionCenterCode, filters[:distribution_center]
                    end

                    order_criteria.ord :PageNumberFilter, xsi_nil(filters[:page_number])
                    order_criteria.ord :PageSize, xsi_nil(filters[:page_size])
                  end
                end
              end
            end
          end
        end

        @last_request = client.http
        @last_response = soap_response.http
      end # get_order_list

    private

      def self.build_id_list(parent, list)
        unless list.nil?
          type = case list.first
            when Integer then :int
            when String then :string
          end
          list.each { |id| parent.ord type, id }
        end
      end # self.build_id_list
    end # OrderService
  end # Services
end # ChannelAdvisor