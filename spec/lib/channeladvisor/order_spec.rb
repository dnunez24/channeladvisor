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
          mock_response(:order, :ping, :success)
          status = ChannelAdvisor::Order.ping
          status.should == "OK"
        end
      end

      context "when unsuccessful" do
        it "raises a ChannelAdvisor Service Error" do
          mock_response(:order, :ping, :failure)
          lambda {ChannelAdvisor::Order.ping}.should raise_error ChannelAdvisor::ServiceFailure, "Order Service Unavailable"
        end
      end
    end

    describe ".list" do
      context "with no filters" do
        context "returning 0 orders" do
          it "raises a No Result Error" do
            mock_response(:order, :get_order_list, :no_match)
            orders = ChannelAdvisor::Order.list
            orders.should == nil
          end
        end
        context "returning 1 order" do
          it "returns an array of 1 order object" do
            mock_response(:order, :get_order_list, :one_match)
            orders = ChannelAdvisor::Order.list
            orders.first.should be_an_instance_of ChannelAdvisor::Order
            orders.size.should == 1
          end
        end

        context "returning more than 1 order" do
          it "returns an array with more than 1 order object" do
            mock_response(:order, :get_order_list, :no_criteria)
            orders = ChannelAdvisor::Order.list
            orders.first.should be_an_instance_of ChannelAdvisor::Order
            orders.size.should be > 1
          end
        end
      end

      context "with filter" do
        describe "created after 11/11/11" do
          it "returns only orders created after 11/11/11" do
            mock_response(:order, :get_order_list, :created_from)
            orders = ChannelAdvisor::Order.list :created_from => DateTime.new(2011, 11, 11)
            orders.first.order_time_gmt.should be >= DateTime.new(2011, 11, 11)
          end
        end

        describe "created before 11/11/11" do
          it "returns only orders created before 11/11/11" do
            mock_response(:order, :get_order_list, :created_to)
            orders = ChannelAdvisor::Order.list :created_to => DateTime.new(2011, 11, 11)
            orders.first.order_time_gmt.should be <= DateTime.new(2011, 11, 11)
          end
        end

        describe "created between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
          it "returns only orders created between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
            mock_response(:order, :get_order_list, :created_between)
            orders = ChannelAdvisor::Order.list :created_from => DateTime.new(2011, 11, 11, 00, 00, 00), :created_to => DateTime.new(2011, 11, 11, 02, 00, 00)
            orders.first.order_time_gmt.should be >= DateTime.new(2011, 11, 11, 00, 00, 00)
            orders.last.order_time_gmt.should be <= DateTime.new(2011, 11, 11, 02, 00, 00)
          end
        end

        describe "updated after 11/11/11" do
          it "returns only orders updated after 11/11/11" do
            mock_response(:order, :get_order_list, :updated_from)
            orders = ChannelAdvisor::Order.list :updated_from => DateTime.new(2011, 11, 11)
            sorted_orders = orders.sort_by { |order| order.last_update_date }
            sorted_orders.first.last_update_date.should be >= DateTime.new(2011, 11, 11)
          end
        end

        describe "updated before 11/11/11" do
          it "returns only orders updated before 11/11/11" do
            mock_response(:order, :get_order_list, :updated_to)
            orders = ChannelAdvisor::Order.list :updated_to => DateTime.new(2011, 11, 11)
            sorted_orders = orders.sort_by { |order| order.last_update_date }
            sorted_orders.last.last_update_date.should be <= DateTime.new(2011, 11, 11)
          end
        end

        describe "updated between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
          it "returns only orders updated between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
            mock_response(:order, :get_order_list, :updated_between)
            orders = ChannelAdvisor::Order.list(
              :updated_from => DateTime.new(2011, 11, 11, 00, 00, 00),
              :updated_to => DateTime.new(2011, 11, 11, 02, 00, 00)
            )
            sorted_orders = orders.sort_by { |order| order.last_update_date }
            sorted_orders.first.last_update_date.should be >= DateTime.new(2011, 11, 11, 00, 00, 00)
            sorted_orders.last.last_update_date.should be <= DateTime.new(2011, 11, 11, 02, 00, 00)
          end
        end

        describe "detail level" do
        	context "when valid" do
	          it "returns an array of orders" do
              mock_response(:order, :get_order_list, :valid_detail_level)
	            orders = ChannelAdvisor::Order.list(:detail_level => 'Low')
	            orders.first.should be_an_instance_of ChannelAdvisor::Order
	          end
        	end

        	context "when invalid" do
        	  it "raises an error" do
              mock_response(:order, :get_order_list, :invalid_detail, ["500", "Internal Server Error"])
	            lambda{ ChannelAdvisor::Order.list(:detail_level => 'Junk') }.should raise_error Savon::SOAP::Fault, /'Junk' is not a valid value for DetailLevelType/
        	  end
        	end
        end

        describe "order ID list" do
          context "with 3 valid order IDs" do
            it "sends a SOAP request with an order ID list" do
              pending
              mock_response(:order, :get_order_list, :valid_order_ids)
              soap = double 'soap'
              soap.should_receive(:xml).with(/<ord:OrderIDList>\s*(<ord:int>\d+<\/ord:int>\s*)+<\/ord:OrderIDList>/)
              order_ids = [9505559, 9578802, 9589767]
              orders = ChannelAdvisor::Order.list(:order_ids => order_ids)
            end

            it "returns 3 orders with matching order IDs" do
              mock_response(:order, :get_order_list, :valid_order_ids)
              order_ids = [9505559, 9578802, 9589767]
              orders = ChannelAdvisor::Order.list(:order_ids => order_ids)
              orders.should have(3).items
              orders.each { |order| order_ids.should include(order.order_id.to_i) }
            end
          end
        end
      end
    end
  end
end
