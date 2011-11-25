require 'spec_helper'

def stub_wsdl
  FakeWeb.register_uri(
    :get,
    "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx?WSDL",
    :body => File.expand_path("../../../fixtures/wsdls/order_service.xml", __FILE__)
  )
end

module ChannelAdvisor
  describe Order, ".ping" do
    before(:all) { stub_wsdl }

    subject { described_class.ping }

    context "when successful" do
      stub_response :order, :ping, :success
      it { should == 'OK' }
    end

    context "when unsuccessful" do
      it "raises a Service Failure error" do
        stub_response :order, :ping, :failure
        expect { subject.ping }.to raise_error ServiceFailure, "Order Service Unavailable"
      end
    end
  end

  describe Order, ".list" do
    before(:all) { stub_wsdl }
    after(:all) { FakeWeb.clean_registry }

    let(:request) { FakeWeb.last_request.body }

    shared_examples "a standard filter" do |name|
      context "when not given" do
        it "sends a SOAP request with an xsi:nil type #{name} element" do
          stub_response :order, :get_order_list, :no_criteria
          ChannelAdvisor::Order.list
          request.should contain_nil_element element
        end
      end

      context "when valid" do
        before { stub_response :order, :get_order_list, :"valid_#{name.symbolize}" }

        it "sends a SOAP request with a #{name} element" do
          ChannelAdvisor::Order.list(filters)
          request.should contain_element(element).with(filters.values.first)
        end

        it "returns only orders with a matching #{name}" do
          orders = ChannelAdvisor::Order.list(filters)
          orders.each do |order|
            filters.each do |k, v|
              order.send(k).should == v
            end
          end
        end
      end

      context "when invalid" do
        it "raises a SOAP Fault error" do
          stub_response :order, :get_order_list, :"invalid_#{name.symbolize}", ['500', 'Internal Server Error']
          expect { described_class.list }.to raise_error SoapFault
        end
      end
    end

    context "with no filters" do
      context "when receiving no orders" do
        it "returns an empty array" do
          stub_response(:order, :get_order_list, :no_match)
          orders = ChannelAdvisor::Order.list
          orders.should be_empty
        end
      end

      context "when receiving 1 order" do
        it "returns an array of 1 order" do
          stub_response(:order, :get_order_list, :one_match)
          orders = ChannelAdvisor::Order.list
          orders.each { |order| order.should be_an_instance_of described_class }
          orders.size.should == 1
        end
      end

      context "when receiving more than 1 order" do
        it "returns an array with more than 1 order" do
          stub_response(:order, :get_order_list, :no_criteria)
          orders = ChannelAdvisor::Order.list
          orders.each { |order| order.should be_an_instance_of described_class }
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
          request.should contain_element('ord:DetailLevel').with('Low')
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
          lambda { ChannelAdvisor::Order.list(:detail_level => 'Junk') }.should raise_error SoapFault, /'Junk' is not a valid value for DetailLevelType/
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
          request.should contain_element('ord:ExportState').with('NotExported')
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
          lambda { ChannelAdvisor::Order.list(:export_state => 'Junk') }.should raise_error SoapFault, /'Junk' is not a valid value for ExportStateType/
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
          order_ids.each do |id|
            request.should contain_element('ord:OrderIDList').with("<ord:int>#{id}</ord:int>")
          end
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
          client_order_ids.each do |id|
            request.should contain_element("ord:ClientOrderIdentifierList").with("<ord:string>#{id}</ord:string>")
          end
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
          request.should contain_element('ord:OrderStateFilter').with('Cancelled')
        end

        it "returns only orders with a matching order state" do
          stub_response(:order, :get_order_list, :valid_order_state)
          orders = ChannelAdvisor::Order.list(:state => 'Cancelled')
          orders.each { |order| order.state.should == 'Cancelled' }
        end
      end
    end

    describe "payment status filter" do
      let(:filters) { {:payment_status => 'Failed'} }
      let(:element) { 'ord:PaymentStatusFilter' }
      it_should_behave_like "a standard filter", 'payment status'
    end

    describe "checkout status filter" do
      let(:filters) { {:checkout_status => 'NotVisited'} }
      let(:element) { 'ord:CheckoutStatusFilter' }
      it_should_behave_like "a standard filter", 'checkout status'
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
          request.should contain_element('ord:ShippingStatusFilter').with('Unshipped')
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
          lambda { ChannelAdvisor::Order.list(:shipping_status => 'Junk') }.should raise_error SoapFault, /'Junk' is not a valid value for ShippingStatusCode/
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
          request.should contain_element('ord:RefundStatusFilter').with('OrderLevel')
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
          lambda { ChannelAdvisor::Order.list(:refund_status => 'Junk') }.should raise_error SoapFault, /'Junk' is not a valid value for OrderRefundStatusCode/
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
          request.should contain_element('ord:DistributionCenterCode').with('Wilsonville')
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
          request.should contain_element('ord:PageNumberFilter').with('2')
        end

        it "returns orders from the corresponding page" do
          pending
          stub_response :order, :get_order_list, :valid_page_number_1
          stub_response :order, :get_order_list, :valid_page_number_2
          ChannelAdvisor::Order.list(:page_number => 2)
          request.should contain_element('ord:PageNumberFilter').with(2)
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
  end # Order
end # ChannelAdvisor
