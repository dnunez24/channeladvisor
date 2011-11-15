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
          FakeWeb.register_uri(
            :post,
            "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx",
            :body => File.expand_path("../../../fixtures/responses/order_service/ping_success.xml", __FILE__)
          )
          status = ChannelAdvisor::Order.ping
          status.should == "Success"
        end
      end

      context "when unsuccessful" do
        it "raises a ChannelAdvisor Service Error" do
          FakeWeb.register_uri(
            :post,
            "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx",
            :body => File.expand_path("../../../fixtures/responses/order_service/ping_failure.xml", __FILE__)
          )
          lambda {ChannelAdvisor::Order.ping}.should raise_error ChannelAdvisor::ServiceFailure, "Order Service Unavailable"
        end
      end
    end

    describe ".list" do
      context "without filters" do
        context "returning 0 orders" do
          it "raises a No Matches error" do
            FakeWeb.register_uri(
              :post,
              "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx",
              :body => File.expand_path("../../../fixtures/responses/order_service/list_no_match.xml", __FILE__)
            )
            lambda {ChannelAdvisor::Order.list}.should raise_error ChannelAdvisor::NoResultError, "No order data returned in the response"
          end
        end
        context "returning 1 order" do
          it "returns an array of order objects"
        end

        context "returning more than 1 order" do
          it "returns an array of order objects" do
            orders = ChannelAdvisor::Order.list
            orders.first.should be_an_instance_of ChannelAdvisor::Order
          end
        end
      end

      context "with filters" do
        describe "created after 11/11/11 00:00:00" do
          it "returns only orders created after 11/11/11 00:00:00" do
            FakeWeb.register_uri(
              :post,
              "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx",
              :body => File.expand_path("../../../fixtures/responses/order_service/list_created_from.xml", __FILE__)
            )
            orders = ChannelAdvisor::Order.list :created_from => DateTime.new(2011, 11, 11, 00, 00, 00)
            orders.first.order_time_gmt.should be >= DateTime.new(2011, 11, 11, 00, 00, 00)
          end
        end

        describe "created before 11/11/11 00:00:00" do
          it "returns only orders created before 11/11/11" do
            FakeWeb.register_uri(
              :post,
              "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx",
              :body => File.expand_path("../../../fixtures/responses/order_service/list_created_to.xml", __FILE__)
            )
            orders = ChannelAdvisor::Order.list :created_to => DateTime.new(2011, 11, 11, 00, 00, 00)
            orders.first.order_time_gmt.should be <= DateTime.new(2011, 11, 11, 00, 00, 00)
          end
        end

        describe "created between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
          it "returns only orders created between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
            FakeWeb.register_uri(
              :post,
              "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx",
              :body => File.expand_path("../../../fixtures/responses/order_service/list_created_between.xml", __FILE__)
            )
            orders = ChannelAdvisor::Order.list :created_from => DateTime.new(2011, 11, 11, 00, 00, 00), :created_to => DateTime.new(2011, 11, 11, 02, 00, 00)
            orders.first.order_time_gmt.should be >= DateTime.new(2011, 11, 11, 00, 00, 00)
            orders.last.order_time_gmt.should be <= DateTime.new(2011, 11, 11, 02, 00, 00)
          end
        end

        describe "updated after 11/11/11 00:00:00" do
          it "returns only orders updated after 11/11/11 00:00:00" do
            FakeWeb.register_uri(
              :post,
              "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx",
              :body => File.expand_path("../../../fixtures/responses/order_service/list_updated_from.xml", __FILE__)
            )
            orders = ChannelAdvisor::Order.list :updated_from => DateTime.new(2011, 11, 11, 00, 00, 00)
            sorted_orders = orders.sort_by { |order| order.last_update_date }
            sorted_orders.first.last_update_date.should be >= DateTime.new(2011, 11, 11, 00, 00, 00)
          end
        end

        describe "updated before 11/11/11 00:00:00" do
          it "returns only orders updated before 11/11/11 00:00:00" do
            FakeWeb.register_uri(
              :post,
              "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx",
              :body => File.expand_path("../../../fixtures/responses/order_service/list_updated_to.xml", __FILE__)
            )
            orders = ChannelAdvisor::Order.list :updated_to => DateTime.new(2011, 11, 11, 00, 00, 00)
            sorted_orders = orders.sort_by { |order| order.last_update_date }
            sorted_orders.last.last_update_date.should be <= DateTime.new(2011, 11, 11, 00, 00, 00)
          end
        end

        describe "updated between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
          it "returns only orders updated between 11/11/11 00:00:00 and 11/11/11 02:00:00" do
            FakeWeb.register_uri(
              :post,
              "https://api.channeladvisor.com/ChannelAdvisorAPI/v5/OrderService.asmx",
              :body => File.expand_path("../../../fixtures/responses/order_service/list_updated_between.xml", __FILE__)
            )
            orders = ChannelAdvisor::Order.list(
              :updated_from => DateTime.new(2011, 11, 11, 00, 00, 00),
              :updated_to => DateTime.new(2011, 11, 11, 02, 00, 00)
            )
            sorted_orders = orders.sort_by { |order| order.last_update_date }
            sorted_orders.first.last_update_date.should be >= DateTime.new(2011, 11, 11, 00, 00, 00)
            sorted_orders.last.last_update_date.should be <= DateTime.new(2011, 11, 11, 02, 00, 00)
          end
        end

        describe "with detail level 'low'" do
          it "returns orders with lowest level of detail"
        end
      end
    end
  end
end
