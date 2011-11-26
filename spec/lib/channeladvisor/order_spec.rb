require 'spec_helper'

def stub_wsdl
  FakeWeb.register_uri(
    :get,
    "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx?WSDL",
    :body => File.expand_path("../../../fixtures/wsdls/order_service.xml", __FILE__)
  )
end

def stub_response(method, data, status=nil)
  file_name = data.kind_of?(String) ? data : data.to_s
  response_xml = File.expand_path("../../../fixtures/responses/order_service/#{method.to_s}/#{file_name}.xml", __FILE__)
  response = {:body => response_xml}
  response.update(:status => status) unless status.nil?

  FakeWeb.register_uri(
    :post,
    "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx",
    response
  )
end

module ChannelAdvisor
  describe Order, ".ping" do
    before(:all)  { stub_wsdl }
    before(:each) { stub_response :ping, data }
    subject { described_class.ping }

    context "when successful" do
      let(:data) { :success }

      it { should == 'OK' }
    end

    context "when unsuccessful" do
      let(:data) { :failure }

      it "raises a Service Failure error" do
        expect { subject }.to raise_error ServiceFailure
      end
    end
  end

  describe Order, ".list" do
    before(:all)  { stub_wsdl }
    before(:each) do
      status ||= nil
      stub_response :get_order_list, data, status
    end
    after(:all)   { FakeWeb.clean_registry }

    let(:request) { FakeWeb.last_request.body }

    shared_examples "a standard filter" do |name|
      context "when not given" do
        let(:data) { :no_criteria }

        it "sends a SOAP request with an xsi:nil type #{name.stringify} element" do
          ChannelAdvisor::Order.list
          request.should contain_nil_element element
        end
      end

      context "when valid" do
        let(:data) { "valid_#{name.to_s}" }

        it "sends a SOAP request with a #{name.stringify} element" do
          ChannelAdvisor::Order.list(filters)
          request.should contain_element(element).with(filters.values.first)
        end

        it "returns only orders with a matching #{name.stringify}" do
          orders = ChannelAdvisor::Order.list(filters)
          orders.each do |order|
            filters.each do |k, v|
              order.send(k).should == v
            end
          end
        end
      end

      context "when invalid" do
        let(:data) { "invalid_#{name.to_s}" }
        let(:status) { ['500', 'Internal Server Error'] }
        
        it "raises a SOAP Fault error" do
          expect { described_class.list }.to raise_error SoapFault
        end
      end
    end

    context "with no filters" do
      subject { described_class.list }

      context "when receiving no orders" do
        let(:data) { :no_match }
        it { should be_an Array }
        it { should be_empty }
      end

      context "when receiving 1 order" do
        let(:data) { :one_match }

        it "returns an array of 1 order" do
          subject.size.should == 1
          subject.first.should be_an_instance_of described_class
        end
      end

      context "when receiving more than 1 order" do
        let(:data) { :no_criteria }

        it "returns an array with more than 1 order" do
          subject.size.should be > 1
          subject.each { |order| order.should be_an_instance_of described_class }
        end
      end
    end

    shared_examples "a date filter" do |name|
      context "when not given" do
        let(:data) { :no_criteria }

        it "sends a SOAP request with an xsi:nil type #{name.stringify} element" do
          described_class.list
          request.should contain_nil_element element
        end
      end
      
      /(_from|_to)/.match(name) do |m|
        context "when valid" do
          let(:data) { "valid_#{name}_date" }
          let(:date) { DateTime.new(2011, 11, 11) }

          it "sends a SOAP request with a #{name.stringify} element" do
            described_class.list name => date
            request.should contain_element(element).with(date.strftime("%Y-%m-%dT%H:%M:%S"))
          end

          it "returns only orders bound by the supplied date" do
            orders = described_class.list name => date
            action = "#{$`}_at".clone.to_sym
            case m[1]
            when "from"
              orders.each { |order| order.send(action).should be >= date }
            when "to"
              orders.each { |order| order.send(action).should be <= date }
            end
          end
        end
      end

      context "when invalid" do
        let(:data) { :invalid_date_filter }
        let(:status) { ['500', 'Internal Server Error'] }

        it "raises a SOAP Fault error" do
          expect { described_class.list }.to raise_error SoapFault
        end
      end
    end

    describe "created from filter" do
      let(:element) { 'ord:OrderCreationFilterBeginTimeGMT' }
      it_should_behave_like "a date filter", :created_from
    end

    describe "created to filter" do
      let(:element) { 'ord:OrderCreationFilterEndTimeGMT' }
      it_should_behave_like "a date filter", :created_to
    end

    describe "updated from filter" do
      let(:element) { 'ord:StatusUpdateFilterBeginTimeGMT' }
      it_should_behave_like "a date filter", :updated_from
    end

    describe "updated to filter" do
      let(:element) { 'ord:StatusUpdateFilterEndTimeGMT' }
      it_should_behave_like "a date filter", :updated_to
    end

    context "with created to and from filters" do
      let(:data) { :valid_created_between_dates }
      it "returns only orders with a created at date between the two filters" do
        pending
      end
    end

    context "with created from and to filters " do
      describe "using 11/11/11 00:00:00 to 11/11/11 02:00:00" do
        let(:data) { :valid_created_between_dates }

        it "returns only orders created between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
          orders = ChannelAdvisor::Order.list :created_from => DateTime.new(2011, 11, 11, 00, 00, 00), :created_to => DateTime.new(2011, 11, 11, 02, 00, 00)
          orders.first.created_at.should be >= DateTime.new(2011, 11, 11, 00, 00, 00)
          orders.last.created_at.should be <= DateTime.new(2011, 11, 11, 02, 00, 00)
        end
      end
    end

    context "with updated from and to filters" do
      describe "using 11/11/11 00:00:00 to 11/11/11 02:00:00" do
        let(:data) { :valid_updated_between_dates }

        it "returns only orders updated between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
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
        let(:data) { :no_criteria }

        it "sends a SOAP request with an xsi:nil DetailLevel element" do
          ChannelAdvisor::Order.list
          request.should contain_nil_element "ord:DetailLevel"
        end
      end

    	describe "using a valid value" do
        let(:data) { :valid_detail_level }

        it "sends a SOAP request with a DetailLevel element" do
          ChannelAdvisor::Order.list(:detail_level => 'Low')
          request.should contain_element('ord:DetailLevel').with('Low')
        end

        it "returns an array of orders" do
          orders = ChannelAdvisor::Order.list(:detail_level => 'Low')
          orders.each { |order| order.should be_an_instance_of ChannelAdvisor::Order }
        end
    	end

    	describe "using an invalid value" do
        let(:data) { :invalid_detail_level }
        let(:status) { ['500', 'Internal Server Error'] }

    	  it "raises a SOAP Fault Error" do
          expect { described_class.list }.to raise_error SoapFault
    	  end
    	end
    end

    context "with export state filter" do
      describe "not given" do
        let(:data) { :no_criteria }

        it "sends a SOAP request with an xsi:nil ExportState element" do
          ChannelAdvisor::Order.list
          request.should contain_nil_element "ord:ExportState"
        end
      end

      describe "using a valid value" do
        let(:data) { :valid_export_state }

        it "sends a SOAP request with an ExportState element" do
          ChannelAdvisor::Order.list(:export_state => 'NotExported')
          request.should contain_element('ord:ExportState').with('NotExported')
        end

        it "returns an array of orders" do
          orders = ChannelAdvisor::Order.list(:export_state => 'NotExported')
          orders.each { |order| order.should be_an_instance_of ChannelAdvisor::Order }
        end
      end

      describe "using an invalid value" do
        let(:data)    { :invalid_export_state }
        let(:status)  { ['500', 'Internal Server Error'] }

        it "raises a SOAP Fault Error" do
          expect { described_class.list }.to raise_error SoapFault
        end
      end
    end

    context "with order ID list filter" do
      let(:data) { :valid_order_ids }
      
      describe "not given" do
        it "sends a SOAP request without the OrderIDList element" do
          ChannelAdvisor::Order.list
          request.should_not contain_element('ord:OrderIDList')
        end
      end

      describe "containing 3 valid order IDs" do
        it "sends a SOAP request with an order ID list" do
          order_ids = [9505559, 9578802, 9589767]
          ChannelAdvisor::Order.list(:order_ids => order_ids)
          order_ids.each do |id|
            request.should contain_element('ord:OrderIDList').with("<ord:int>#{id}</ord:int>")
          end
        end

        it "returns 3 orders with matching order IDs" do
          order_ids = [9505559, 9578802, 9589767]
          orders = ChannelAdvisor::Order.list(:order_ids => order_ids)
          orders.should have(3).items
          orders.each { |order| order_ids.should include order.id.to_i }
        end
      end
    end

    context "with client order ID list filter" do
      describe "not given" do
        let(:data) { :no_criteria }

        it "sends a SOAP request without the ClientOrderIdentifierList element" do
          ChannelAdvisor::Order.list
          request.should_not contain_element('ord:ClientOrderIdentifierList')
        end
      end

      describe "containing 2 valid client order IDs" do
        let(:data) { :valid_client_order_ids }

        it "sends a SOAP request with a client order ID list" do
          client_order_ids = ['103-2623013-3383425', '104-3096697-0099456']
          ChannelAdvisor::Order.list(:client_order_ids => client_order_ids)
          client_order_ids.each do |id|
            request.should contain_element("ord:ClientOrderIdentifierList").with("<ord:string>#{id}</ord:string>")
          end
        end

        it "returns 2 orders with matching client order IDs" do
          client_order_ids = ['103-2623013-3383425', '104-3096697-0099456']
          orders = ChannelAdvisor::Order.list(:client_order_ids => client_order_ids)
          orders.should have(2).items
          orders.each { |order| client_order_ids.should include order.client_order_id }
        end
      end
    end

    describe "order state filter" do
      let(:filters) { {:state => 'Cancelled'} }
      let(:element) { 'ord:OrderStateFilter' }
      it_should_behave_like "a standard filter", :order_state
    end

    describe "payment status filter" do
      let(:filters) { {:payment_status => 'Failed'} }
      let(:element) { 'ord:PaymentStatusFilter' }
      it_should_behave_like "a standard filter", :payment_status
    end

    describe "checkout status filter" do
      let(:filters) { {:checkout_status => 'NotVisited'} }
      let(:element) { 'ord:CheckoutStatusFilter' }
      it_should_behave_like "a standard filter", :checkout_status
    end

    describe "shipping status filter" do
      let(:filters)  { {:shipping_status => 'Unshipped'} }
      let(:element) { 'ord:ShippingStatusFilter' }
      it_should_behave_like "a standard filter", :shipping_status
    end

    describe "refund status filter" do
      let(:filters) { {:refund_status => 'OrderLevel'} }
      let(:element) { 'ord:RefundStatusFilter' }
      it_should_behave_like "a standard filter", :refund_status
    end

    context "with distribution center filter" do
      describe "not given" do
        let(:data) { :no_criteria }

        it "sends a SOAP request without a DistributionCenterCode element" do
          ChannelAdvisor::Order.list
          request.should_not contain_element('ord:DistributionCenterCode')
        end
      end

      describe "using a valid value" do
        let(:data) { :valid_distribution_center }

        it "sends a SOAP request with a DistributionCenterCode element" do
          ChannelAdvisor::Order.list(:distribution_center => 'Wilsonville')
          request.should contain_element('ord:DistributionCenterCode').with('Wilsonville')
        end

        it "returns only orders with a matching distribution center" do
          orders = ChannelAdvisor::Order.list(:distribution_center => 'Wilsonville')
          orders.each do |order|
            order.items.each do |item|
              item.distribution_center == 'Wilsonville'
            end
          end
        end
      end

      describe "using an invalid value" do
        let(:data) { :invalid_distribution_center }

        it "returns an empty array" do
          orders = ChannelAdvisor::Order.list(:distribution_center => 'Junk')
          orders.should be_empty
        end
      end
    end

    context "with page number filter" do
      describe "not given" do
        let(:data) { :no_criteria }

        it "sends a SOAP request with an xsi:nil PageNumberFilter element" do
          ChannelAdvisor::Order.list
          request.should contain_nil_element "ord:PageNumberFilter"
        end
      end

      describe "using a valid value" do
        let(:data) { :valid_page_number_2 }

        it "sends a SOAP request with a PageNumberFilter element" do
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
        let(:data) { :invalid_page_number }
        it "returns a SOAP Fault error" do
          pending
          # Input string was not in a correct format.
        end
      end
    end
  end # Order
end # ChannelAdvisor
