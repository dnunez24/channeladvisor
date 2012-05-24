require 'spec_helper'

module ChannelAdvisor
  describe Order do
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
          before {@orders = Order.list(:order_ids => [14161613, 14162751]) }

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
      before { @order = Order.new(14162751, :client_order_id => "14162751") }

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
            order = Order.new(12345678, :client_order_id => "12345678")
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
            mock.proxy(Services::OrderService).set_orders_export_status(["14162751"], false)
            Order.set_export_status(["14162751"], false)
          end

          it "returns a hash with one client order ID and boolean result" do
            result = Order.set_export_status(["14162751"], false)
            result.should == {"14162751" => true}
          end
        end

        context "with two client order IDs" do
          use_vcr_cassette "responses/order/set_export_status/success/with_two_client_order_ids"

          it "sends the client order IDs and export statuses to OrderService.set_orders_export_status" do
            mock.proxy(Services::OrderService).set_orders_export_status(["14162751", "14161613"], false)
            Order.set_export_status(["14162751", "14161613"], false)
          end

          it "returns a hash with two client order IDs and boolean results" do
            result = Order.set_export_status(["14162751", "14161613"], false)
            result.should == {"14162751" => true, "14161613" => true}
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
