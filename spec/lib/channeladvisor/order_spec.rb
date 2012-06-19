require 'spec_helper'

module ChannelAdvisor
  describe Order do
    describe ".new" do
      let(:attrs) do
        {
          :number_of_matches=>"2",
          :order_time_gmt=> DateTime.parse("2012-05-16T15:44:27+00:00 ((2456064j,56667s,683000000n),+0s,2299161j)"),
          :last_update_date=> DateTime.parse("2012-05-16T15:44:27+00:00 ((2456064j,56667s,723000000n),+0s,2299161j)"),
          :total_order_amount=>"44.9200",
          :order_state=>"Active",
          :date_cancelled_gmt=>DateTime.new(2012,05,17),
          :order_id=>"14161613",
          :client_order_identifier=>"14161613",
          :seller_order_id=>"EFGH5678",
          :reseller_id=>"999999",
          :buyer_email_address=>"test@example.com",
          :email_opt_in=>false,
          :flag_description=>nil,
          :custom_value_list=>{},
          :buyer_ip_address=>"50.29.99.129",
          :transaction_notes=>"Example notes",
          :"@xmlns:q1"=>"http://api.channeladvisor.com/datacontracts/orders",
          :"@xsi:type"=>"q1:OrderResponseDetailComplete"
        }
      end

      subject { Order.new(attrs) }

      its(:created_at)            { should == attrs[:order_time_gmt]          }
      its(:updated_at)            { should == attrs[:last_update_date]        }
      its(:total)                 { should == attrs[:total_order_amount].to_f }
      its(:state)                 { should == attrs[:order_state]             }
      its(:cancelled_on)          { should == attrs[:date_cancelled_gmt]      }
      its(:id)                    { should == attrs[:order_id].to_i           }
      its(:client_id)             { should == attrs[:client_order_identifier] }
      its(:seller_id)             { should == attrs[:seller_order_id]         }
      its(:reseller_id)           { should == attrs[:reseller_id]             }
      its(:buyer_email)           { should == attrs[:buyer_email_address]     }
      its(:email_opt_in)          { should == attrs[:email_opt_in]            }
      its(:flag_description)      { should == attrs[:flag_description]        }
      its(:custom_values)         { should == attrs[:custom_value_list]       }
      its(:buyer_ip_address)      { should == attrs[:buyer_ip_address]        }
      its(:transaction_notes)     { should == attrs[:transaction_notes]       }

      context "with shipping info" do
        let(:attrs) do
          {
            :shipping_info=> {
              :shipping_instructions => "do some stuff",
              :estimated_ship_date => DateTime.new(2012,05,18),
              :delivery_date => DateTime.new(2012,05,21),
              :shipment_list => {
                :shipment => {:shipping_carrier => "UPS", :shipping_class => "GND", :tracking_number => "1234567890"}
              }
            }
          }
        end

        its(:shipping_instructions) { should == attrs[:shipping_info][:shipping_instructions]   }
        its(:estimated_ship_date)   { should == attrs[:shipping_info][:estimated_ship_date]     }
        its(:delivery_date)         { should == attrs[:shipping_info][:delivery_date]           }

        context "with one shipment" do
          before(:each) do
            stub.proxy(Shipment).new
            @order = Order.new(attrs)
          end

          it "creates a new shipment object from the attributes hash" do
            shipment = attrs[:shipping_info][:shipment_list][:shipment]
            Shipment.should have_received.new(shipment)
          end

          it "creates a @shipments collection with one shipment" do
            @order.shipments.should have(1).shipment
            @order.shipments.first.should be_a Shipment
          end
        end

        context "with two shipments" do
          before(:each) do
            @shipments = attrs[:shipping_info][:shipment_list] = {
              :shipment => [
                {:shipping_carrier => "FedEx", :shipping_class => "Home Delivery", :tracking_number => "999999"},
                {:shipping_carrier => "UPS", :shipping_class => "Ground", :tracking_number => "1234567"}
              ]
            }
            stub.proxy(Shipment).new
            @order = Order.new(attrs)
          end

          it "creates a @shipments collection with two shipments" do
            @order.shipments.should have(2).shipments
            @order.shipments.each do |shipment|
              shipment.should be_a Shipment
            end
          end

          it "creates a new shipment object for each shipment in the attribute hash" do
            @shipments[:shipment].each do |shipment|
              Shipment.should have_received.new(shipment)
            end
          end
        end
      end


      context "with order_status in the attributes hash" do
        let(:attrs) do
          {:order_status => {}}
        end

        its(:status) { should be_an OrderStatus }

        it "sets @status to an OrderStatus object" do
          stub(OrderStatus).new
          Order.new(attrs)
          OrderStatus.should have_received.new(attrs[:order_status])
        end
      end

      context "with payment_info in the attributes hash" do
        let(:attrs) do
          {:payment_info => {}}
        end

        its(:payment) { should be_a Payment }

        it "sets @payment to a Payment object" do
          stub(Payment).new
          Order.new(attrs)
          Payment.should have_received.new(attrs[:payment_info])
        end
      end


      context "with billing_address in the attributes hash" do
        let(:attrs) do
          {:billing_info => {:billing_stuff => nil}}
        end

        its(:billing_address) { should be_an Address }

        it "sets @billing_address to an Address object" do
          stub(Address).new
          order = Order.new(attrs)
          Address.should have_received.new(attrs[:billing_info])
        end
      end

      context "with shipping_address in the attributes hash" do
        let(:attrs) do
          {:shipping_info => {:shipping_stuff => nil}}
        end

        its(:shipping_address) { should be_an Address }

        it "sets @shipping_address to an Address object" do
          stub(Address).new
          order = Order.new(attrs)
          Address.should have_received.new(attrs[:shipping_info])
        end
      end

      context "with shopping_cart in the attributes hash" do
        let(:attrs) do
          {:shopping_cart => {}}
        end

        its(:shopping_cart) { should be_a ShoppingCart }

        it "sets @shopping_cart to a ShoppingCart object" do
          stub(ShoppingCart).new
          Order.new(attrs)
          ShoppingCart.should have_received.new(attrs[:shopping_cart])
        end
      end
    end

    describe "#items_ship_cost" do
      let(:items) { [@item] }

      before(:each) do
        @order = Order.new
        @item = Object.new
        stub(@item).shipping_cost { 1.50 }
        stub(@order).shopping_cart.stub!.items { items }
      end

      context "with one item" do
        it "returns the shipping cost of the order item" do
          @order.items_ship_cost.should == 1.50
        end

        context "when item shipping cost is 0.00" do
          it "returns 0.00" do
            stub(@item).shipping_cost { 0.00 }
            @order.items_ship_cost.should == 0.00
          end
        end
      end

      context "with two items" do
        let(:items) { [@item, @item] }

        it "returns the cumulative shipping cost of all order items" do
          @order.items_ship_cost.should == 3.00
        end
      end
    end

    describe "#invoice_ship_cost" do
      before(:each) do
        @order = Order.new
        invoice = Object.new
        stub(invoice).type { "Shipping" }
        stub(invoice).unit_price { unit_price }
        stub(@order).shopping_cart.stub!.invoices { [invoice] }
      end

      context "when shipping cost is 0" do
        let(:unit_price) { 0.00 }

        it "returns nil" do
          @order.invoice_ship_cost.should == nil
        end
      end

      context "when shipping cost is not 0" do
        let(:unit_price) { 5.99 }

        it "returns the shipping cost from the shipping invoice" do
          @order.invoice_ship_cost.should == 5.99
        end
      end
    end

    describe "#total_ship_cost" do
      before(:each) do
        @order = Order.new
      end
      context "when the invoice shipping cost is nil" do
        it "returns the items shipping cost" do
          stub(@order).invoice_ship_cost { nil }
          stub(@order).items_ship_cost { 5.99 }
          @order.total_ship_cost.should == 5.99
        end
      end

      context "when the invoice shipping cost is not nil" do
        it "returns the invoice shipping cost" do
          stub(@order).invoice_ship_cost { 2.99 }
          @order.total_ship_cost.should == 2.99
        end
      end
    end

    describe ".ping" do
      use_vcr_cassette "responses/order/ping"

      it "sends a ping request to the Order Service" do
        mock.proxy(Services::OrderService).ping
        Order.ping
      end

      context "with a success status" do
        use_vcr_cassette "responses/order/ping/success"

        it "returns true" do
          Order.ping.should be_true
        end
      end

      context "with a failure status" do
        failure = {:code => 1, :message => "Service Unavailable"}
        use_vcr_cassette "responses/order/ping/failure", :erb => failure

        it "raises a ServiceFailure error" do
          expect { Order.ping }.to raise_error ServiceFailure, failure[:message]
        end
      end

      context "with a SOAP fault" do
        use_vcr_cassette "responses/soap_fault", :match_requests_on => [:method]

        it "raises a SOAP fault error" do
          ChannelAdvisor.configure { |c| c.developer_key = "WRONG" }
          expect { Order.ping }.to raise_error SOAPFault, "Server was unable to process request. Authentication failed."
        end

        it "stores the SOAP fault code" do
          begin
            Order.ping
          rescue SOAPFault => fault
            fault.code.should == "soap:Server"
          end
        end
      end

      context "with an HTTP error" do
        http_status = {:code => 500, :message => "Internal Server Error"}
        use_vcr_cassette "responses/http_error", :match_requests_on => [:method], :erb => http_status

        it "raises an HTTP error" do
          expect { Order.ping }.to raise_error HTTPError, "Failed with HTTP error #{http_status[:code]}"
        end

        it "stores the HTTP status code" do
          begin
            Order.ping
          rescue HTTPError => error
            error.code.should == http_status[:code]
          end
        end
      end
    end

    describe ".list" do
      context "with a success status" do
        context "with no matching orders" do
          use_vcr_cassette "responses/order/list/no_matching_orders"

          it "returns a collection with zero orders" do
            orders = Order.list(:order_ids => [00000000])
            orders.should have(0).orders
          end
        end

        context "with one matching order" do
          use_vcr_cassette "responses/order/list/one_matching_order"
          before { @orders = Order.list(:order_ids => [14161613]) }

          it "returns a collection with one order" do
            @orders.should have(1).order
          end

          it "contains only order objects" do
            @orders.each do |order|
              order.should be_an Order
            end
          end
        end

        context "with two matching orders" do
          use_vcr_cassette "responses/order/list/two_matching_orders"
          before { @orders = Order.list(:order_ids => [14161613, 14162751]) }

          it "returns a collection with two orders" do
            @orders.should have(2).orders
          end

          it "contains only order objects" do
            @orders.each do |order|
              order.should be_an Order
            end
          end
        end
      end

      context "with a failure status" do
        use_vcr_cassette "responses/order/list/failure"

        it "raises a ServiceFailure error" do
          message = "Extreme is not a valid value for DetailLevel"
          expect { Order.list(:detail_level => "Extreme") }.to raise_error ServiceFailure, message
        end
      end

      context "with a SOAP fault" do
        use_vcr_cassette "responses/soap_fault", :match_requests_on => [:method]

        it "raises a SOAP fault error" do
          ChannelAdvisor.configure { |c| c.developer_key = "WRONG" }
          expect { Order.list }.to raise_error SOAPFault, "Server was unable to process request. Authentication failed."
        end

        it "stores the SOAP fault code" do
          begin
            Order.list
          rescue SOAPFault => fault
            fault.code.should == "soap:Server"
          end
        end
      end

      context "with an HTTP error" do
        http_status = {:code => 500, :message => "Internal Server Error"}
        use_vcr_cassette "responses/http_error", :match_requests_on => [:method], :erb => http_status

        it "raises an HTTP error" do
          expect { Order.list }.to raise_error HTTPError, "Failed with HTTP error #{http_status[:code]}"
        end

        it "stores the HTTP status code" do
          begin
            Order.list
          rescue HTTPError => error
            error.code.should == http_status[:code]
          end
        end
      end

      context "with no criteria" do
        use_vcr_cassette "responses/order/list/with_no_criteria"

        it "sends a list request to the Order Service without criteria" do
          mock.proxy(Services::OrderService).get_order_list({})
          Order.list
        end
      end

      context "with criteria" do
        use_vcr_cassette "responses/order/list/with_criteria"

        before(:each) do
          @criteria = {
            :created_from         => DateTime.new(2012,05,15),
            :created_to           => DateTime.new(2012,05,17),
            :updated_from         => DateTime.new(2012,05,15),
            :updated_to           => DateTime.new(2012,05,17),
            :join_dates           => false,
            :detail_level         => "Low",
            :export_state         => "NotExported",
            :order_ids            => [123456, 567890],
            :client_order_ids     => ["ABCD1234", "EFGH5678"],
            :state                => "Active",
            :payment_status       => "Cleared",
            :checkout_status      => "Completed",
            :shipping_status      => "Unshipped",
            :refund_status        => "NoRefunds",
            :distribution_center  => "ABC",
            :page_number          => 1,
            :page_size            => 25
          }
        end

        it "sends criteria to OrderService.get_order_list" do
          mock.proxy(Services::OrderService).get_order_list(@criteria)
          Order.list(@criteria)
        end

        context "with created_between date range criteria" do
          it "sends only created_from and created_to criteria to OrderService.get_order_list" do
            date_range = DateTime.new(2012,05,20)..DateTime.new(2012,05,25)
            new_criteria = @criteria.merge(:created_between => date_range)
            @criteria.merge!(:created_from => date_range.first, :created_to => date_range.last)

            mock.proxy(Services::OrderService).get_order_list(@criteria)
            Order.list(new_criteria)
          end
        end

        context "with updated_between date range criteria" do
          it "sends only updated_from and updated_to criteria to OrderService.get_order_list" do
            date_range = DateTime.new(2012,05,20)..DateTime.new(2012,05,25)
            new_criteria = @criteria.merge(:updated_between => date_range)
            @criteria.merge!(:updated_from => date_range.first, :updated_to => date_range.last)

            mock.proxy(Services::OrderService).get_order_list(@criteria)
            Order.list(new_criteria)
          end
        end
      end
    end # list

    describe "#set_export_status" do
      use_vcr_cassette "responses/order/instance_set_export_status"
      before { @order = Order.new(:order_id => 14162751, :client_order_identifier => "14162751") }

      it "sends the client order ID and export status to OrderService.set_orders_export_status" do
        mock.proxy(Services::OrderService).set_orders_export_status(["14162751"], false)
        @order.set_export_status(false)
      end

      context "with a success status" do
        context "with a result of true" do
          use_vcr_cassette "responses/order/instance_set_export_status/success/result_true", :exclusive => true

          it "returns true" do
            result = @order.set_export_status(false)
            result.should == true
          end
        end

        context "with a result of false" do
          use_vcr_cassette "responses/order/instance_set_export_status/success/result_false", :exclusive => true

          it "returns false" do
            order = Order.new(:order_id => 12345678, :client_order_id => "12345678")
            result = order.set_export_status(false)
            result.should == false
          end
        end
      end

      context "with a failure status" do
        failure = {:code => 1, :message => "Service Unavailable"}
        use_vcr_cassette "responses/order/instance_set_export_status/failure", :erb => failure

        it "raises a ServiceFailure error" do
          expect { @order.set_export_status(false) }.to raise_error ServiceFailure, failure[:message]
        end
      end

      context "with a SOAP fault" do
        use_vcr_cassette "responses/soap_fault", :match_requests_on => [:method]

        it "raises a SOAP fault error" do
          ChannelAdvisor.configure { |c| c.developer_key = "WRONG" }
          expect { Order.list }.to raise_error SOAPFault, "Server was unable to process request. Authentication failed."
        end

        it "stores the SOAP fault code" do
          begin
            @order.set_export_status(false)
          rescue SOAPFault => fault
            fault.code.should == "soap:Server"
          end
        end
      end

      context "with an HTTP error" do
        http_status = {:code => 500, :message => "Internal Server Error"}
        use_vcr_cassette "responses/http_error", :match_requests_on => [:method], :erb => http_status

        it "raises an HTTP error" do
          expect { @order.set_export_status(false) }.to raise_error HTTPError, "Failed with HTTP error #{http_status[:code]}"
        end

        it "stores the HTTP status code" do
          begin
            @order.set_export_status(false)
          rescue HTTPError => error
            error.code.should == http_status[:code]
          end
        end
      end
    end # #set_export_status

    describe ".set_export_status" do
      context "with a success status" do
        context "with one client order ID" do
          use_vcr_cassette "responses/order/set_export_status/success/with_one_client_order_id"

          it "sends the client order ID and export status to OrderService.set_orders_export_status" do
            stub.proxy(Services::OrderService).set_orders_export_status
            Order.set_export_status("14162751", false)
            Services::OrderService.should have_received.set_orders_export_status(["14162751"], false)
          end

          it "returns a hash with one client order ID and boolean result" do
            result = Order.set_export_status("14162751", false)
            result.should be_a_boolean
          end
        end

        context "with two client order IDs" do
          use_vcr_cassette "responses/order/set_export_status/success/with_two_client_order_ids"

          let(:client_order_ids) { ["14162751", "14161613"] }

          it "sends the client order IDs and export statuses to OrderService.set_orders_export_status" do
            stub.proxy(Services::OrderService).set_orders_export_status
            Order.set_export_status(client_order_ids, false)
            Services::OrderService.should have_received.set_orders_export_status(client_order_ids, false)
          end

          context "with a true and false result" do
            it "returns a hash with boolean results" do
              result = {
                true => [client_order_ids[0]],
                false => [client_order_ids[1]]
              }
              response = Order.set_export_status(client_order_ids, false)
              response.should == result
            end
          end

          context "with all true results" do
            use_vcr_cassette "responses/order/set_export_status/success/with_two_client_order_ids/both_true"

            it "returns a hash where false in an empty array" do
              result = {
                true => [client_order_ids[0], client_order_ids[1]],
                false => []
              }
              response = Order.set_export_status(client_order_ids, false)
              response.should == result
            end
          end

          context "with all false results" do
            use_vcr_cassette "responses/order/set_export_status/success/with_two_client_order_ids/both_false"

            it "returns a hash where true is an empty array" do
              result = {
                true => [],
                false => [client_order_ids[0], client_order_ids[1]]
              }
              response = Order.set_export_status(client_order_ids, false)
              response.should == result
            end
            
          end
        end
      end

      context "with a failure status" do
        failure = {:code => 1, :message => "Service Unavailable"}
        use_vcr_cassette "responses/order/set_export_status/failure", :erb => failure

        it "raises a ServiceFailure error" do
          expect { Order.set_export_status(["14162751"], false) }.to raise_error ServiceFailure, failure[:message]
        end
      end

      context "with a SOAP fault" do
        use_vcr_cassette "responses/soap_fault", :match_requests_on => [:method]

        it "raises a SOAP fault error" do
          ChannelAdvisor.configure { |c| c.developer_key = "WRONG" }
          expect { Order.list }.to raise_error SOAPFault, "Server was unable to process request. Authentication failed."
        end

        it "stores the SOAP fault code" do
          begin
            Order.set_export_status(["14162751"], false)
          rescue SOAPFault => fault
            fault.code.should == "soap:Server"
          end
        end
      end

      context "with an HTTP error" do
        http_status = {:code => 500, :message => "Internal Server Error"}
        use_vcr_cassette "responses/http_error", :match_requests_on => [:method], :erb => http_status

        it "raises an HTTP error" do
          expect { Order.set_export_status(["14162751"], false) }.to raise_error HTTPError, "Failed with HTTP error #{http_status[:code]}"
        end

        it "stores the HTTP status code" do
          begin
            Order.set_export_status(["14162751"], false)
          rescue HTTPError => error
            error.code.should == http_status[:code]
          end
        end
      end
    end # .set_export_status
  end # Order
end # ChannelAdvisor
