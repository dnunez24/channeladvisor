module ChannelAdvisor
  class Order < Base
    attr_accessor :id, :client_id, :seller_id, :state, :created_at, :updated_at, :total, :cancelled_on, :flag_description,
    :reseller_id, :buyer_email, :buyer_ip_address, :email_opt_in, :shipping_instructions, :delivery_date, :estimated_ship_date,
    :transaction_notes, :status, :billing_address, :shipping_address, :payment, :shipments, :shopping_cart, :custom_values

    def initialize(attrs={})
      @id                 = attrs[:order_id].to_i
      @client_id          = attrs[:client_order_identifier]
      @seller_id          = attrs[:seller_order_id]
      @state              = attrs[:order_state]
      @created_at         = attrs[:order_time_gmt]
      @updated_at         = attrs[:last_update_date]
      @cancelled_on       = attrs[:date_cancelled_gmt]
      @total              = attrs[:total_order_amount].to_f
      @reseller_id        = attrs[:reseller_id]
      @flag_description   = attrs[:flag_description]
      @buyer_email        = attrs[:buyer_email_address]
      @email_opt_in       = attrs[:email_opt_in]
      @buyer_ip_address   = attrs[:buyer_ip_address]
      @transaction_notes  = attrs[:transaction_notes]
      @custom_values      = attrs[:custom_value_list]
      @status             = OrderStatus.new(attrs[:order_status])   if attrs[:order_status]
      @payment            = Payment.new(attrs[:payment_info])       if attrs[:payment_info]
      @billing_address    = Address.new(attrs[:billing_info])       if attrs[:billing_info]
      @shipping_address   = Address.new(attrs[:shipping_info])      if attrs[:shipping_info]
      @shopping_cart      = ShoppingCart.new(attrs[:shopping_cart]) if attrs[:shopping_cart]

      if shipping_info = attrs[:shipping_info]
        @shipping_instructions  = shipping_info[:shipping_instructions]
        @estimated_ship_date    = shipping_info[:estimated_ship_date]
        @delivery_date          = shipping_info[:delivery_date]

        if shipment_list = shipping_info[:shipment_list]
          @shipments = arrayify(shipment_list[:shipment]).map { |s| Shipment.new(s) }
        end
      end
    end

    # Set the export status for a given order instance
    #
    # @param [Boolean] mark_as_exported `true` (`Exported`) or `false` (`NotExported`)
    #
    # @raise [ServiceFailure] If the service returns a Failure status
    # @raise [SOAPFault] If the service responds with a SOAP fault
    # @raise [HTTPError] If the service responds with an HTTP error
    #
    # @return [Boolean] Returns the boolean result for changing the export status
    def set_export_status(mark_as_exported)
      handle_errors do
        response = Services::OrderService.set_orders_export_status([@client_id], mark_as_exported)
        result = response[:set_orders_export_status_response][:set_orders_export_status_result]
        check_status_of result
        return result[:result_data][:boolean]
      end
    end

    def total_ship_cost
      invoice_ship_cost || items_ship_cost
    end

    def invoice_ship_cost
      shopping_cart.invoices.select { |i| i.type == "Shipping" }.first.unit_price.nonzero?
    end

    def items_ship_cost
      shopping_cart.items.collect { |i| i.shipping_cost }.inject(:+)
    end

    class << self
      # Check authorization for and availability of the order service
      #
      # @raise [ServiceFailure] If the service returns a Failure status
      # @raise [SOAPFault] If the service responds with a SOAP fault
      # @raise [HTTPError] If the service responds with an HTTP error
      #
      # @return [Boolean] Returns `true` if SOAP response status is `Success`
      def ping
        handle_errors do
          response = Services::OrderService.ping
          result = response[:ping_response][:ping_result]
          check_status_of result
        end
      end

      # Retrieve a list of orders, restricted by the provided criteria
      #
      # @example List orders created between 11/11/2011 and 11/15/2011
      # 	ChannelAdvisor::Order.list(:created_between => DateTime.new(2011,11,11)..DateTime.new(2011,11,15))
      #
      # @param [Hash] criteria Criteria used to filter the order list
      # @option criteria [Range<DateTime>] :created_between Range of order creation date-times in UTC (instead of `created_from` and `created_to`)
      # @option criteria [Range<DateTime>] :updated_between Range of order update date-times in UTC (instead of `updated_from` and `updated_to`)
      # @option criteria [DateTime] :created_from Order creation begin time in UTC
      # @option criteria [DateTime] :created_to Order creation end time in UTC
      # @option criteria [DateTime] :updated_from Order update begin time in UTC
      # @option criteria [DateTime] :updated_to Order update end time in UTC
      # @option criteria [Boolean] :join_dates `true` indicates that orders can satisfy either
      # 	the created date range or the updated date range
      # @option criteria [String] :detail_level `Low`, `Medium`, `High` or `Complete`
      # @option criteria [String] :export_state `Unknown`, `NotExported` or `Exported`
      # @option criteria [Array<Integer>] :order_ids Array of order IDs
      # @option criteria [Array<String>] :client_order_ids Array of client order IDs
      # @option criteria [String] :state `Active`, `Archived`, or `Cancelled`
      # @option criteria [String] :payment_status `NoChange`, `NotSubmitted`, `Cleared`, `Submitted`, `Failed`, or `Deposited`
      # @option criteria [String] :checkout_status `NoChange`, `NotVisited`, `Completed`, `Visited`, `Cancelled`, `CompletedOffline`, or `OnHold`
      # @option criteria [String] :shipping_status `NoChange`, `Unshipped`, `PendingShipment`, `PartiallyShipped`, or `Shipped`
      # @option criteria [String] :refund_status `NoRefunds`, `OrderLevel`, `LineItemLevel`, `OrderAndLineItemLevel`, or `FailedAttemptsOnly`
      # @option criteria [String] :distribution_center Only orders containing at least one item from the specified distribution center
      # @option criteria [Integer] :page_number Page number of result set
      # @option criteria [Integer] :page_size Size of each page in result set
      #
      # @raise [ServiceFailure] If the service returns a Failure status
      # @raise [SOAPFault] If the service responds with a SOAP fault
      # @raise [HTTPError] If the service responds with an HTTP error
      #
      # @return [Array<Order>] Returns an array of {Order} objects or an empty array
      def list(criteria = {})
        handle_errors do
          if created_between = criteria.delete(:created_between)
            criteria[:created_from]  = created_between.first
            criteria[:created_to]    = created_between.last
          end

          if updated_between = criteria.delete(:updated_between)
            criteria[:updated_from]  = updated_between.first
            criteria[:updated_to]    = updated_between.last
          end

          response = Services::OrderService.get_order_list(criteria)
          result = response[:get_order_list_response][:get_order_list_result]
          check_status_of result
          orders = []

          if data = result[:result_data]
            arrayify(data[:order_response_item]).each { |o| orders << new(o) }
          end

          return orders
        end
      end

      # Set the export status for the provided client order identifiers
      #
      # @param [Boolean] mark_as_exported `true` (`Exported`) or `false` (`NotExported`)
      #
      # @raise [ServiceFailure] If the service returns a Failure status
      # @raise [SOAPFault] If the service responds with a SOAP fault
      # @raise [HTTPError] If the service responds with an HTTP error
      #
      # @return [Hash] Returns a hash of client order IDs and their corresponding boolean results
      def set_export_status(client_order_ids, mark_as_exported)
        handle_errors do
          response = Services::OrderService.set_orders_export_status(client_order_ids, mark_as_exported)
          result = response[:set_orders_export_status_response][:set_orders_export_status_result]
          check_status_of result

          bools = arrayify result[:result_data][:boolean]
          result_hash = {}

          bools.each do |bool|
            client_order_ids.each do |client_order_id|
              result_hash[client_order_id] = bool
            end
          end

          return result_hash
        end
      end
    end
  end # Order
end # ChannelAdvisor
