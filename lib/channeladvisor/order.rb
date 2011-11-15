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
        status
      end
    end

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
                  build_filter xml, :DetailLevel, filters[:detail_level]
                  build_filter xml, :OrderCreationFilterBeginTimeGMT, filters[:created_from]
                  build_filter xml, :OrderCreationFilterEndTimeGMT, filters[:created_to]
                  build_filter xml, :StatusUpdateFilterBeginTimeGMT, filters[:updated_from]
                  build_filter xml, :StatusUpdateFilterEndTimeGMT, filters[:updated_to]
                  build_filter xml, :OrderStateFilter, filters[:state]
                  build_filter xml, :PaymentStatusFilter, filters[:payment_status]
                  build_filter xml, :CheckoutStatusFilter, filters[:checkout_status]
                  build_filter xml, :ShippingStatusFilter, filters[:shipping_status]
                  build_filter xml, :PageNumberFilter, filters[:page_number]
                  build_filter xml, :PageSize, filters[:page_size]
                end
              end
            end
          end
        end
      end

      result_data = response.to_hash[:get_order_list_response][:get_order_list_result][:result_data]

      if result_data.nil?
        raise NoResultError, "No order data returned in the response"
      else
        orders = []

        [result_data[:order_response_item]].flatten.each do |order|
          orders << Order.new(order)
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
        parent.ord element, nil, "xsi:nil" => true
      else
        parent.ord element, filter
      end
    end
  end
end
