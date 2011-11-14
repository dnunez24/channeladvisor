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
									build_criterion xml, :DetailLevel, criteria[:detail_level]
									build_criterion xml, :OrderCreationFilterBeginTimeGMT, criteria[:created_from]
									build_criterion xml, :OrderCreationFilterEndTimeGMT, criteria[:created_to]
									build_criterion xml, :StatusUpdateFilterBeginTimeGMT, criteria[:updated_from]
									build_criterion xml, :StatusUpdateFilterEndTimeGMT, criteria[:updated_to]
									build_criterion xml, :OrderStateFilter, criteria[:state]
									build_criterion xml, :PaymentStatusFilter, criteria[:payment_status]
									build_criterion xml, :CheckoutStatusFilter, criteria[:checkout_status]
									build_criterion xml, :ShippingStatusFilter, criteria[:shipping_status]
									build_criterion xml, :PageNumberFilter, criteria[:page_number]
									build_criterion xml, :PageSize, criteria[:page_size]
								end
							end
						end
					end
				end
			end

			order_array = []
			orders = []

			order_array << response.to_hash[:get_order_list_response][:get_order_list_result][:result_data][:order_response_item]

			order_array.flatten.each do |order|
				orders << Order.new(order)
			end

			return orders
		end

		private

		def self.client
			Connection.client "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx?WSDL"
		end

		def self.build_criterion(parent, element, criterion)
			if criterion.nil?
				parent.ord element, nil, "xsi:nil" => true
			else
				parent.ord element, criterion
			end
		end
	end
end
