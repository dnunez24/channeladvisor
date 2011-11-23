require 'spec_helper'

module ChannelAdvisor
  describe Order do
    before(:all) do
      FakeWeb.register_uri(
        :get,
        "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx?WSDL",
        :body => File.expand_path("../../../fixtures/wsdls/order_service.xml", __FILE__)
      )
    end

    after(:each) do
      FakeWeb.clean_registry
    end

    describe ".ping" do
      context "when successful" do
        it "returns a Success status" do
          stub_response(:order, :ping, :success)
          status = ChannelAdvisor::Order.ping
          status.should == "OK"
        end
      end

      context "when unsuccessful" do
        it "raises a ChannelAdvisor Service Error" do
          stub_response(:order, :ping, :failure)
          lambda {ChannelAdvisor::Order.ping}.should raise_error ChannelAdvisor::ServiceFailure, "Order Service Unavailable"
        end
      end
    end

    describe ".list" do
      context "with no filters" do
        describe "with no orders" do
          it "raises a No Result Error" do
            stub_response(:order, :get_order_list, :no_match)
            orders = ChannelAdvisor::Order.list
            orders.should == nil
          end
        end

        describe "with 1 order" do
          it "returns an array of 1 order object" do
            stub_response(:order, :get_order_list, :one_match)
            orders = ChannelAdvisor::Order.list
            orders.first.should be_an_instance_of ChannelAdvisor::Order
            orders.size.should == 1
          end
        end

        describe "with more than 1 order" do
          it "returns an array with more than 1 order object" do
            stub_response(:order, :get_order_list, :no_criteria)
            orders = ChannelAdvisor::Order.list
            orders.first.should be_an_instance_of ChannelAdvisor::Order
            orders.size.should be > 1
          end
        end
      end

      context "with created from filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil OrderCreationFilterBeginTimeGMT element" do
            stub_response(:order, :get_order_list, :no_criteria)
            mock.instance_of(HTTPI::Request).body=(/<ord:OrderCreationFilterBeginTimeGMT xsi:nil="true"><\/ord:OrderCreationFilterBeginTimeGMT>/)
            ChannelAdvisor::Order.list
          end
        end

        describe "using 11/11/11" do
          it "returns only orders created after 11/11/11" do
            stub_response(:order, :get_order_list, :created_from)
            orders = ChannelAdvisor::Order.list :created_from => DateTime.new(2011, 11, 11)
            orders.first.order_time_gmt.should be >= DateTime.new(2011, 11, 11)
          end
        end
      end

      context "with created to filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil OrderCreationFilterEndTimeGMT element" do
            stub_response(:order, :get_order_list, :no_criteria)
            mock.instance_of(HTTPI::Request).body=(/<ord:OrderCreationFilterEndTimeGMT xsi:nil="true"><\/ord:OrderCreationFilterEndTimeGMT>/)
            ChannelAdvisor::Order.list
          end
        end

        describe "using 11/11/11" do
          it "returns only orders created before 11/11/11" do
            stub_response(:order, :get_order_list, :created_to)
            orders = ChannelAdvisor::Order.list :created_to => DateTime.new(2011, 11, 11)
            orders.first.order_time_gmt.should be <= DateTime.new(2011, 11, 11)
          end
        end
      end

      context "with created from and to filters " do
        describe "using 11/11/11 00:00:00 to 11/11/11 02:00:00" do
          it "returns only orders created between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
            stub_response(:order, :get_order_list, :created_between)
            orders = ChannelAdvisor::Order.list :created_from => DateTime.new(2011, 11, 11, 00, 00, 00), :created_to => DateTime.new(2011, 11, 11, 02, 00, 00)
            orders.first.order_time_gmt.should be >= DateTime.new(2011, 11, 11, 00, 00, 00)
            orders.last.order_time_gmt.should be <= DateTime.new(2011, 11, 11, 02, 00, 00)
          end
        end
      end

      context "with updated from filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil StatusUpdateFilterEndTimeGMT element" do
            stub_response(:order, :get_order_list, :no_criteria)
            mock.instance_of(HTTPI::Request).body=(/<ord:StatusUpdateFilterEndTimeGMT xsi:nil="true"><\/ord:StatusUpdateFilterEndTimeGMT>/)
            ChannelAdvisor::Order.list
          end
        end

        describe "using 11/11/11" do
          it "returns only orders updated after 11/11/11" do
            stub_response(:order, :get_order_list, :updated_from)
            orders = ChannelAdvisor::Order.list :updated_from => DateTime.new(2011, 11, 11)
            sorted_orders = orders.sort_by { |order| order.last_update_date }
            sorted_orders.first.last_update_date.should be >= DateTime.new(2011, 11, 11)
          end
        end
      end

      context "with updated to filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil StatusUpdateFilterEndTimeGMT element" do

          end
        end
        describe "using 11/11/11" do
          it "returns only orders updated before 11/11/11" do
            stub_response(:order, :get_order_list, :updated_to)
            orders = ChannelAdvisor::Order.list :updated_to => DateTime.new(2011, 11, 11)
            sorted_orders = orders.sort_by { |order| order.last_update_date }
            sorted_orders.last.last_update_date.should be <= DateTime.new(2011, 11, 11)
          end
        end
      end

      context "with updated from and to filters" do
        describe "using 11/11/11 00:00:00 to 11/11/11 02:00:00" do
          it "returns only orders updated between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
            stub_response(:order, :get_order_list, :updated_between)
            orders = ChannelAdvisor::Order.list(
              :updated_from => DateTime.new(2011, 11, 11, 00, 00, 00),
              :updated_to => DateTime.new(2011, 11, 11, 02, 00, 00)
            )
            sorted_orders = orders.sort_by { |order| order.last_update_date }
            sorted_orders.first.last_update_date.should be >= DateTime.new(2011, 11, 11, 00, 00, 00)
            sorted_orders.last.last_update_date.should be <= DateTime.new(2011, 11, 11, 02, 00, 00)
          end
        end
      end

      context "with detail level filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil DetailLevel element" do
            stub_response(:order, :get_order_list, :no_criteria)
            mock.instance_of(HTTPI::Request).body=(/<ord:DetailLevel xsi:nil="true"><\/ord:DetailLevel>/)
            ChannelAdvisor::Order.list
          end
        end

      	describe "using a valid value" do
          it "sends a SOAP request with a DetailLevel element" do
            stub_response(:order, :get_order_list, :valid_detail_level)
            mock.instance_of(HTTPI::Request).body=(/<ord:DetailLevel>Low<\/ord:DetailLevel>/)
            ChannelAdvisor::Order.list(:detail_level => 'Low')
          end

          it "returns an array of orders" do
            stub_response(:order, :get_order_list, :valid_detail_level)
            orders = ChannelAdvisor::Order.list(:detail_level => 'Low')
            orders.each { |order| order.should be_an_instance_of ChannelAdvisor::Order }
          end
      	end

      	describe "using an invalid value" do
      	  it "raises a SOAP Fault Error" do
            stub_response(:order, :get_order_list, :invalid_detail_level, ["500", "Internal Server Error"])
            lambda { ChannelAdvisor::Order.list(:detail_level => 'Junk') }.should raise_error Savon::SOAP::Fault, /'Junk' is not a valid value for DetailLevelType/
      	  end
      	end
      end

      context "with export state filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil ExportState element" do
            stub_response :order, :get_order_list, :no_criteria
            mock.instance_of(HTTPI::Request).body=(/<ord:ExportState xsi:nil="true"><\/ord:ExportState>/)
            ChannelAdvisor::Order.list
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with an ExportState element" do
            stub_response(:order, :get_order_list, :valid_export_state)
            mock.instance_of(HTTPI::Request).body=(/<ord:ExportState>NotExported<\/ord:ExportState>/)
            ChannelAdvisor::Order.list(:export_state => 'NotExported')
          end

          it "returns an array of orders" do
            stub_response(:order, :get_order_list, :valid_export_state)
            orders = ChannelAdvisor::Order.list(:export_state => 'NotExported')
            orders.each { |order| order.should be_an_instance_of ChannelAdvisor::Order }
          end
        end

        describe "using an invalid value" do
          it "raises a SOAP Fault Error" do
            stub_response(:order, :get_order_list, :invalid_export_state, ['500', 'Internal Server Error'])
            lambda { ChannelAdvisor::Order.list(:export_state => 'Junk') }.should raise_error Savon::SOAP::Fault, /'Junk' is not a valid value for ExportStateType/
          end
        end
      end

      context "with order ID list filter" do
        describe "not given" do
          it "sends a SOAP request without the OrderIDList element" do
            stub_response(:order, :get_order_list, :valid_order_ids)
            mock.instance_of(HTTPI::Request).body=(/(?!<ord:OrderIDList>.*<\/ord:OrderIDList>)/s)
            ChannelAdvisor::Order.list
          end
        end

        describe "containing 3 valid order IDs" do
          it "sends a SOAP request with an order ID list" do
            stub_response(:order, :get_order_list, :valid_order_ids)
            mock.instance_of(HTTPI::Request).body=(/<ord:OrderIDList>\s*(<ord:int>\d+<\/ord:int>\s*)+<\/ord:OrderIDList>/)
            order_ids = [9505559, 9578802, 9589767]
            ChannelAdvisor::Order.list(:order_ids => order_ids)
          end

          it "returns 3 orders with matching order IDs" do
            stub_response(:order, :get_order_list, :valid_order_ids)
            order_ids = [9505559, 9578802, 9589767]
            orders = ChannelAdvisor::Order.list(:order_ids => order_ids)
            orders.should have(3).items
            orders.each { |order| order_ids.should include order.order_id.to_i }
          end
        end
      end

      context "with client order ID list filter" do
        describe "not given" do
          it "sends a SOAP request without the ClientOrderIdentifierList element" do
            stub_response(:order, :get_order_list, :no_criteria)
            mock.instance_of(HTTPI::Request).body=(/(?!<ord:ClientOrderIdentifierList>.*<\/ord:ClientOrderIdentifierList>)/s)
            ChannelAdvisor::Order.list
          end
        end

        describe "containing 2 valid client order IDs" do
          it "sends a SOAP request with a client order ID list" do
            stub_response(:order, :get_order_list, :valid_client_order_ids)
            mock.instance_of(HTTPI::Request).body=(/<ord:ClientOrderIdentifierList>\s*(<ord:string>[-0-9]+<\/ord:string>\s*)+<\/ord:ClientOrderIdentifierList>/)
            client_order_ids = ['103-2623013-3383425', '104-3096697-0099456']
            ChannelAdvisor::Order.list(:client_order_ids => client_order_ids)
          end

          it "returns 2 orders with matching client order IDs" do
            stub_response :order, :get_order_list, :valid_client_order_ids
            client_order_ids = ['103-2623013-3383425', '104-3096697-0099456']
            orders = ChannelAdvisor::Order.list(:client_order_ids => client_order_ids)
            orders.should have(2).items
            orders.each { |order| client_order_ids.should include order.client_order_identifier }
          end
        end
      end

      context "with order state filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil OrderStateFilter element" do
            stub_response(:order, :get_order_list, :no_criteria)
            mock.instance_of(HTTPI::Request).body=(/<ord:OrderStateFilter xsi:nil="true"><\/ord:OrderStateFilter>/)
            ChannelAdvisor::Order.list
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with an OrderStateFilter element" do
            stub_response(:order, :get_order_list, :valid_order_state)
            mock.instance_of(HTTPI::Request).body=(/<ord:OrderStateFilter>Active<\/ord:OrderStateFilter>/)
            ChannelAdvisor::Order.list(:state => 'Active')
          end

          it "returns only orders with a matching order state" do
            stub_response(:order, :get_order_list, :valid_order_state)
            orders = ChannelAdvisor::Order.list(:state => 'Active')
            orders.each { |order| ['Active', 'Cancelled'].should include order.order_state }
          end
        end
      end

      context "with payment status filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil PaymentStatusFilter element" do
            stub_response(:order, :get_order_list, :no_criteria)
            mock.instance_of(HTTPI::Request).body=(/<ord:PaymentStatusFilter xsi:nil="true"><\/ord:PaymentStatusFilter>/)
            ChannelAdvisor::Order.list
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with a PaymentStatusFilter element" do
            stub_response :order, :get_order_list, :valid_payment_status
            mock.instance_of(HTTPI::Request).body=(/<ord:PaymentStatusFilter>Failed<\/ord:PaymentStatusFilter>/)
            ChannelAdvisor::Order.list(:payment_status => 'Failed')
          end

          it "returns only orders with a matching payment status" do
            stub_response :order, :get_order_list, :valid_payment_status
            orders = ChannelAdvisor::Order.list(:payment_status => 'Failed')
            orders.each { |order| order.payment_status.should == 'Failed' }
          end
        end
      end

      context "with checkout status filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil CheckoutStatusFilter element" do
            stub_response :order, :get_order_list, :no_criteria
            mock.instance_of(HTTPI::Request).body=(/<ord:CheckoutStatusFilter xsi:nil="true"><\/ord:CheckoutStatusFilter>/)
            ChannelAdvisor::Order.list
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with a CheckoutStatusFilter element" do
            stub_response :order, :get_order_list, :valid_checkout_status
            mock.instance_of(HTTPI::Request).body=(/<ord:CheckoutStatusFilter>NotVisited<\/ord:CheckoutStatusFilter>/)
            ChannelAdvisor::Order.list(:checkout_status => 'NotVisited')
          end

          it "returns only orders with a matching checkout status" do
            stub_response :order, :get_order_list, :valid_checkout_status
            orders = ChannelAdvisor::Order.list(:checkout_status => 'NotVisited')
            orders.each { |order| order.checkout_status.should == 'NotVisited' }
          end
        end

        describe "using an invalid value" do
          it "raises a SOAP Fault error" do
            stub_response(:order, :get_order_list, :invalid_checkout_status, ['500', 'Internal Server Error'])
            lambda { ChannelAdvisor::Order.list(:checkout_status => 'Junk') }.should raise_error Savon::SOAP::Fault, /'Junk' is not a valid value for CheckoutStatusCode/
          end
        end
      end

      context "with shipping status filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil ShippingStatusFilter element" do
            stub_response :order, :get_order_list, :no_criteria
            mock.instance_of(HTTPI::Request).body=(/<ord:ShippingStatusFilter xsi:nil="true"><\/ord:ShippingStatusFilter>/)
            ChannelAdvisor::Order.list
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with a ShippingStatusFilter element" do
            stub_response :order, :get_order_list, :valid_checkout_status
            mock.instance_of(HTTPI::Request).body=(/<ord:ShippingStatusFilter>Unshipped<\/ord:ShippingStatusFilter>/)
            ChannelAdvisor::Order.list(:shipping_status => 'Unshipped')
          end

          it "returns only orders with a matching shipping status" do
            stub_response :order, :get_order_list, :valid_shipping_status
            orders = ChannelAdvisor::Order.list(:shipping_status => 'Unshipped')
            orders.each { |order| order.shipping_status.should == 'Unshipped' }
          end
        end

        describe "using an invalid value" do
          it "raises a SOAP Fault error" do
            stub_response(:order, :get_order_list, :invalid_shipping_status, ['500', 'Internal Server Error'])
            lambda { ChannelAdvisor::Order.list(:shipping_status => 'Junk') }.should raise_error Savon::SOAP::Fault, /'Junk' is not a valid value for ShippingStatusCode/
          end
        end
      end
    end # .list
  end # Order
end # ChannelAdvisor
