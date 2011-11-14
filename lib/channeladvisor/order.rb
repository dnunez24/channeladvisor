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
				if key =~ /^\w*$/
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

		def self.list(criteria = {})
			response = client.request "GetOrderList" do
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
									xml.ord :DetailLevel, criteria[:detail_level] if criteria[:detail_level]
									xml.ord :OrderCreationFilterBeginTimeGMT, criteria[:created_from] if criteria[:created_from]
									xml.ord :OrderCreationFilterEndTimeGMT, criteria[:created_to] if criteria[:created_to]
									xml.ord :StatusUpdateFilterBeginTimeGMT, criteria[:updated_from] if criteria[:updated_from]
									xml.ord :StatusUpdateFilterEndTimeGMT, criteria[:updated_to] if criteria[:updated_to]
									xml.ord :OrderStateFilter, criteria[:state] if criteria[:state]
									xml.ord :PaymentStatusFilter, criteria[:payment_status] if criteria[:payment_status]
									xml.ord :CheckoutStatusFilter, criteria[:checkout_status] if criteria[:checkout_status]
									xml.ord :ShippingStatusFilter, criteria[:shipping_status] if criteria[:shipping_status]
									xml.ord :PageNumberFilter, criteria[:page_number] if criteria[:page_number]
									xml.ord :PageSize, criteria[:page_size] if criteria[:page_size]
								end
							end
						end
					end
				end
			end

			orders = response.to_hash[:get_order_list_response][:get_order_list_result][:result_data][:order_response_item]
			result = []

			orders.each do |order|
				result << Order.new(order)
			end

			return result
		end

		private

		def self.client
			Connection.client "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx?WSDL"
		end
	end
end
