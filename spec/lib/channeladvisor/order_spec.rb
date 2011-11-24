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

    let(:request) { FakeWeb.last_request.body }

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
      # before(:each) do
      #   FakeWeb.register_uri(
      #     :post,
      #     "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx",
      #     :body => File.expand_path("../fixtures/responses/order_service/get_order_list/#{response_xml}", __FILE__)
      #   )
      # end

      context "with no filters" do
        describe "with no orders" do
          # let(:response_xml) { 'no_match.xml' }
          it "returns an empty array" do
            stub_response(:order, :get_order_list, :no_match)
            orders = ChannelAdvisor::Order.list
            orders.should be_empty
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
            ChannelAdvisor::Order.list
            request.should contain_nil_element "ord:OrderCreationFilterBeginTimeGMT"
          end
        end

        describe "using 11/11/11" do
          it "returns only orders created after 11/11/11" do
            stub_response(:order, :get_order_list, :created_from)
            orders = ChannelAdvisor::Order.list :created_from => DateTime.new(2011, 11, 11)
            orders.first.created_at.should be >= DateTime.new(2011, 11, 11)
          end
        end
      end

      context "with created to filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil OrderCreationFilterEndTimeGMT element" do
            stub_response(:order, :get_order_list, :no_criteria)
            ChannelAdvisor::Order.list
            request.should contain_nil_element "ord:OrderCreationFilterEndTimeGMT"
          end
        end

        describe "using 11/11/11" do
          it "returns only orders created before 11/11/11" do
            stub_response(:order, :get_order_list, :created_to)
            orders = ChannelAdvisor::Order.list :created_to => DateTime.new(2011, 11, 11)
            orders.first.created_at.should be <= DateTime.new(2011, 11, 11)
          end
        end
      end

      context "with created from and to filters " do
        describe "using 11/11/11 00:00:00 to 11/11/11 02:00:00" do
          it "returns only orders created between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
            stub_response(:order, :get_order_list, :created_between)
            orders = ChannelAdvisor::Order.list :created_from => DateTime.new(2011, 11, 11, 00, 00, 00), :created_to => DateTime.new(2011, 11, 11, 02, 00, 00)
            orders.first.created_at.should be >= DateTime.new(2011, 11, 11, 00, 00, 00)
            orders.last.created_at.should be <= DateTime.new(2011, 11, 11, 02, 00, 00)
          end
        end
      end

      context "with updated from filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil StatusUpdateFilterEndTimeGMT element" do
            stub_response(:order, :get_order_list, :no_criteria)
            ChannelAdvisor::Order.list
            request.should contain_nil_element "ord:StatusUpdateFilterEndTimeGMT"
          end
        end

        describe "using 11/11/11" do
          it "returns only orders updated after 11/11/11" do
            stub_response(:order, :get_order_list, :updated_from)
            orders = ChannelAdvisor::Order.list :updated_from => DateTime.new(2011, 11, 11)
            sorted_orders = orders.sort_by { |order| order.updated_at }
            sorted_orders.first.updated_at.should be >= DateTime.new(2011, 11, 11)
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
            sorted_orders = orders.sort_by { |order| order.updated_at }
            sorted_orders.last.updated_at.should be <= DateTime.new(2011, 11, 11)
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
            sorted_orders = orders.sort_by { |order| order.updated_at }
            sorted_orders.first.updated_at.should be >= DateTime.new(2011, 11, 11, 00, 00, 00)
            sorted_orders.last.updated_at.should be <= DateTime.new(2011, 11, 11, 02, 00, 00)
          end
        end
      end

      context "with detail level filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil DetailLevel element" do
            stub_response(:order, :get_order_list, :no_criteria)
            ChannelAdvisor::Order.list
            request.should contain_nil_element "ord:DetailLevel"
          end
        end

      	describe "using a valid value" do
          it "sends a SOAP request with a DetailLevel element" do
            stub_response(:order, :get_order_list, :valid_detail_level)
            ChannelAdvisor::Order.list(:detail_level => 'Low')
            request.should contain_element('ord:DetailLevel').with_value('Low')
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
            ChannelAdvisor::Order.list
            request.should contain_nil_element "ord:ExportState"
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with an ExportState element" do
            stub_response(:order, :get_order_list, :valid_export_state)
            ChannelAdvisor::Order.list(:export_state => 'NotExported')
            request.should contain_element('ord:ExportState').with_value('NotExported')
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
            ChannelAdvisor::Order.list
            request.should_not contain_element('ord:OrderIDList')
          end
        end

        describe "containing 3 valid order IDs" do
          it "sends a SOAP request with an order ID list" do
            stub_response(:order, :get_order_list, :valid_order_ids)
            order_ids = [9505559, 9578802, 9589767]
            ChannelAdvisor::Order.list(:order_ids => order_ids)
            request.should =~ /<ord:OrderIDList>\s*(<ord:int>\d+<\/ord:int>\s*)+<\/ord:OrderIDList>/
          end

          it "returns 3 orders with matching order IDs" do
            stub_response(:order, :get_order_list, :valid_order_ids)
            order_ids = [9505559, 9578802, 9589767]
            orders = ChannelAdvisor::Order.list(:order_ids => order_ids)
            orders.should have(3).items
            orders.each { |order| order_ids.should include order.id.to_i }
          end
        end
      end

      context "with client order ID list filter" do
        describe "not given" do
          it "sends a SOAP request without the ClientOrderIdentifierList element" do
            stub_response(:order, :get_order_list, :no_criteria)
            ChannelAdvisor::Order.list
            request.should_not contain_element('ord:ClientOrderIdentifierList')
          end
        end

        describe "containing 2 valid client order IDs" do
          it "sends a SOAP request with a client order ID list" do
            stub_response(:order, :get_order_list, :valid_client_order_ids)
            client_order_ids = ['103-2623013-3383425', '104-3096697-0099456']
            ChannelAdvisor::Order.list(:client_order_ids => client_order_ids)
            request.should =~ /<ord:ClientOrderIdentifierList>\s*(<ord:string>[-0-9]+<\/ord:string>\s*)+<\/ord:ClientOrderIdentifierList>/
          end

          it "returns 2 orders with matching client order IDs" do
            stub_response :order, :get_order_list, :valid_client_order_ids
            client_order_ids = ['103-2623013-3383425', '104-3096697-0099456']
            orders = ChannelAdvisor::Order.list(:client_order_ids => client_order_ids)
            orders.should have(2).items
            orders.each { |order| client_order_ids.should include order.client_order_id }
          end
        end
      end

      context "with order state filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil OrderStateFilter element" do
            stub_response(:order, :get_order_list, :no_criteria)
            ChannelAdvisor::Order.list
            request.should contain_nil_element "ord:OrderStateFilter"
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with an OrderStateFilter element" do
            stub_response(:order, :get_order_list, :valid_order_state)
            ChannelAdvisor::Order.list(:state => 'Cancelled')
            request.should =~ /<ord:OrderStateFilter>Cancelled<\/ord:OrderStateFilter>/
          end

          it "returns only orders with a matching order state" do
            stub_response(:order, :get_order_list, :valid_order_state)
            orders = ChannelAdvisor::Order.list(:state => 'Cancelled')
            orders.each { |order| order.state.should == 'Cancelled' }
          end
        end
      end

      context "with payment status filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil PaymentStatusFilter element" do
            stub_response(:order, :get_order_list, :no_criteria)
            ChannelAdvisor::Order.list
            request.should contain_nil_element "ord:PaymentStatusFilter"
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with a PaymentStatusFilter element" do
            stub_response :order, :get_order_list, :valid_payment_status
            ChannelAdvisor::Order.list(:payment_status => 'Failed')
            request.should contain_element('ord:PaymentStatusFilter').with_value('Failed')
          end

          it "returns only orders with a matching payment status" do
            stub_response :order, :get_order_list, :valid_payment_status
            orders = ChannelAdvisor::Order.list(:payment_status => 'Failed')
            orders.each { |order| order.payment_status.should == 'Failed' }
          end
        end
      end

      context "with refund status filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil CheckoutStatusFilter element" do
            stub_response :order, :get_order_list, :no_criteria
            ChannelAdvisor::Order.list
            request.should contain_nil_element "ord:CheckoutStatusFilter"
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with a CheckoutStatusFilter element" do
            stub_response :order, :get_order_list, :valid_checkout_status
            ChannelAdvisor::Order.list(:checkout_status => 'NotVisited')
            request.should contain_element('ord:CheckoutStatusFilter').with_value('NotVisited')
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
            ChannelAdvisor::Order.list
            request.should contain_nil_element "ord:ShippingStatusFilter"
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with a ShippingStatusFilter element" do
            stub_response :order, :get_order_list, :valid_shipping_status
            ChannelAdvisor::Order.list(:shipping_status => 'Unshipped')
            request.should contain_element('ord:ShippingStatusFilter').with_value('Unshipped')
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

      context "with refund status filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil RefundStatusFilter element" do
            stub_response :order, :get_order_list, :no_criteria
            ChannelAdvisor::Order.list
            request.should contain_nil_element "ord:RefundStatusFilter"
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with a RefundStatusFilter element" do
            stub_response :order, :get_order_list, :valid_refund_status
            ChannelAdvisor::Order.list(:refund_status => 'OrderLevel')
            request.should contain_element('ord:RefundStatusFilter').with_value('OrderLevel')
          end

          it "returns only orders with a matching refund status" do
            stub_response :order, :get_order_list, :valid_refund_status
            orders = ChannelAdvisor::Order.list(:refund_status => 'OrderLevel')
            orders.each { |order| order.refund_status == 'OrderLevel' }
          end
        end

        describe "using an invalid value" do
          it "raises a SOAP Fault error" do
            stub_response(:order, :get_order_list, :invalid_refund_status, ['500', 'Internal Server Error'])
            lambda { ChannelAdvisor::Order.list(:refund_status => 'Junk') }.should raise_error Savon::SOAP::Fault, /'Junk' is not a valid value for OrderRefundStatusCode/
          end
        end
      end

      context "with distribution center filter" do
        describe "not given" do
          it "sends a SOAP request without a DistributionCenterCode element" do
            stub_response(:order, :get_order_list, :no_criteria)
            ChannelAdvisor::Order.list
            request.should_not contain_element('ord:DistributionCenterCode')
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with a DistributionCenterCode element" do
            stub_response :order, :get_order_list, :valid_distribution_center
            ChannelAdvisor::Order.list(:distribution_center => 'Wilsonville')
            request.should contain_element('ord:DistributionCenterCode').with_value('Wilsonville')
          end

          it "returns only orders with a matching distribution center" do
            stub_response :order, :get_order_list, :valid_distribution_center
            orders = ChannelAdvisor::Order.list(:distribution_center => 'Wilsonville')
            orders.each do |order|
              order.items.each do |item|
                item.distribution_center == 'Wilsonville'
              end
            end
          end
        end

        describe "using an invalid value" do
          it "returns an empty array" do
            stub_response(:order, :get_order_list, :invalid_distribution_center)
            orders = ChannelAdvisor::Order.list(:distribution_center => 'Junk')
            orders.should be_empty
          end
        end
      end

      context "with page number filter" do
        describe "not given" do
          it "sends a SOAP request with an xsi:nil PageNumberFilter element" do
            stub_response(:order, :get_order_list, :no_criteria)
            ChannelAdvisor::Order.list
            request.should contain_nil_element "ord:PageNumberFilter"
          end
        end

        describe "using a valid value" do
          it "sends a SOAP request with a PageNumberFilter element" do
            stub_response :order, :get_order_list, :valid_page_number_2
            ChannelAdvisor::Order.list(:page_number => 2)
            request.should contain_element('ord:PageNumberFilter').with_value('2')
          end

          it "returns orders from the corresponding page" do
            pending
            stub_response :order, :get_order_list, :valid_page_number_1
            stub_response :order, :get_order_list, :valid_page_number_2
            ChannelAdvisor::Order.list(:page_number => 2)
            request.should =~ /<ord:PageNumberFilter>2<\/ord:PageNumberFilter>/
          end

          it "does not return records from another page" do

          end
        end

        describe "using an invalid value" do
          it "returns a SOAP Fault error" do
            pending
            # Input string was not in a correct format.
          end
        end
      end
    end # .list
  end # Order
end # ChannelAdvisor
