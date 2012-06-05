require 'spec_helper'

module ChannelAdvisor
  describe Order do
    describe ".new" do
      let(:attrs) do
        {:number_of_matches=>"2",
        :order_time_gmt=> DateTime.parse("2012-05-16T15:44:27+00:00 ((2456064j,56667s,683000000n),+0s,2299161j)"),
        :last_update_date=> DateTime.parse("2012-05-16T15:44:27+00:00 ((2456064j,56667s,723000000n),+0s,2299161j)"),
        :total_order_amount=>"44.9200",
        :order_state=>"Active",
        :date_cancelled_gmt=>DateTime.new(2012,05,17),
        :order_id=>"14161613",
        :client_order_identifier=>"14161613",
        :seller_order_id=>"EFGH5678",
        :order_status=>
        {:checkout_status=>"NotVisited",
         :checkout_date_gmt=> DateTime.parse("1900-01-01T00:00:00+00:00 ((2415021j,0s,0n),+0s,2299161j)"),
         :payment_status=>"NotSubmitted",
         :payment_date_gmt=> DateTime.parse("1900-01-01T00:00:00+00:00 ((2415021j,0s,0n),+0s,2299161j)"),
         :shipping_status=>"Unshipped",
         :shipping_date_gmt=> DateTime.parse("1900-01-01T00:00:00+00:00 ((2415021j,0s,0n),+0s,2299161j)"),
         :order_refund_status=>"NoRefunds"},
        :reseller_id=>"999999",
        :buyer_email_address=>"test@example.com",
        :email_opt_in=>false,
        :payment_info=>
        {:payment_type=>nil,
         :credit_card_last4=>nil,
         :pay_pal_id=>nil,
         :merchant_reference_number=>nil,
         :payment_transaction_id=>nil},
        :shipping_info=>
        {:address_line1=>nil,
         :address_line2=>nil,
         :city=>nil,
         :region=>nil,
         :region_description=>nil,
         :postal_code=>nil,
         :country_code=>"US",
         :company_name=>nil,
         :job_title=>nil,
         :title=>nil,
         :first_name=>nil,
         :last_name=>nil,
         :suffix=>nil,
         :phone_number_day=>nil,
         :phone_number_evening=>nil,
         :shipment_list=>
          {:shipment=>
            {:shipping_carrier=>nil, :shipping_class=>nil, :tracking_number=>nil}},
         :shipping_instructions=>"None",
         :estimated_ship_date=>DateTime.new(2012,05,19),
         :delivery_date=>DateTime.new(2012,05,24)},
        :billing_info=>
        {:address_line1=>nil,
         :address_line2=>nil,
         :city=>nil,
         :region=>nil,
         :region_description=>nil,
         :postal_code=>nil,
         :country_code=>nil,
         :company_name=>nil,
         :title=>nil,
         :first_name=>nil,
         :last_name=>nil,
         :suffix=>nil,
         :phone_number_day=>nil,
         :phone_number_evening=>nil},
        :flag_description=>nil,
        :shopping_cart=>
        {:cart_id=>"14161613",
         :checkout_source=>"Unspecified",
         :vat_tax_calculation_option=>"Unspecified",
         :vat_shipping_option=>"Unspecified",
         :vat_gift_wrap_option=>"Unspecified",
         :line_item_sku_list=>
          {:order_line_item_item=>
            [{:line_item_type=>"SKU",
              :unit_price=>"6.9900",
              :line_item_id=>"17293910",
              :allow_negative_quantity=>false,
              :quantity=>"5",
              :item_sale_source=>"DIRECT_SALE",
              :sku=>"FAKE001",
              :title=>"Fake Item No. 1",
              :buyer_user_id=>"test@example.com",
              :buyer_feedback_rating=>"0",
              :sales_source_id=>"37081357",
              :vat_rate=>"0",
              :tax_cost=>"0.0000",
              :shipping_cost=>"0.0000",
              :shipping_tax_cost=>"0.0000",
              :gift_wrap_cost=>"0.0000",
              :gift_wrap_tax_cost=>"0.0000",
              :gift_message=>nil,
              :gift_wrap_level=>nil,
              :recycling_fee=>"0.0000",
              :unit_weight=>"0",
              :warehouse_location=>nil,
              :user_name=>nil,
              :distribution_center_code=>"Wilsonville",
              :is_fba=>false,
              :"@xsi:type"=>"q1:OrderLineItemItemResponse"},
             {:line_item_type=>"SKU",
              :unit_price=>"3.9900",
              :line_item_id=>"17293911",
              :allow_negative_quantity=>false,
              :quantity=>"2",
              :item_sale_source=>"DIRECT_SALE",
              :sku=>"FAKE002",
              :title=>"Fake Item No. 2",
              :buyer_user_id=>"test@example.com",
              :buyer_feedback_rating=>"0",
              :sales_source_id=>"37081358",
              :vat_rate=>"0",
              :tax_cost=>"0.0000",
              :shipping_cost=>"0.0000",
              :shipping_tax_cost=>"0.0000",
              :gift_wrap_cost=>"0.0000",
              :gift_wrap_tax_cost=>"0.0000",
              :gift_message=>nil,
              :gift_wrap_level=>nil,
              :recycling_fee=>"0.0000",
              :unit_weight=>"0",
              :warehouse_location=>nil,
              :user_name=>nil,
              :distribution_center_code=>"Wilsonville",
              :is_fba=>false,
              :"@xsi:type"=>"q1:OrderLineItemItemResponse"}]},
         :line_item_invoice_list=>
          {:order_line_item_invoice=>
            [{:line_item_type=>"SalesTax", :unit_price=>"0.0000"},
             {:line_item_type=>"Shipping", :unit_price=>"0.0000"},
             {:line_item_type=>"ShippingInsurance", :unit_price=>"0.0000"},
             {:line_item_type=>"VATShipping", :unit_price=>"0.0000"},
             {:line_item_type=>"GiftWrap", :unit_price=>"0.0000"},
             {:line_item_type=>"VATGiftWrap", :unit_price=>"0.0000"},
             {:line_item_type=>"RecyclingFee", :unit_price=>"0.0000"}]},
         :line_item_promo_list=>
          {:order_line_item_promo=>
            [{:line_item_type=>"Promotion", :unit_price=>"0.0000", :promo_code=>nil},
             {:line_item_type=>"AdditionalCostOrDiscount",
              :unit_price=>"1.9900",
              :promo_code=>nil}]}},
        :custom_value_list=>{:id_1 => "value 1", :id_2 => "value 2"},
        :buyer_ip_address=>"50.29.99.129",
        :transaction_notes=>"Example notes",
        :"@xmlns:q1"=>"http://api.channeladvisor.com/datacontracts/orders",
        :"@xsi:type"=>"q1:OrderResponseDetailComplete"}
      end

      subject { Order.new(attrs) }

      its(:id)                    { should == attrs[:order_id].to_i           }
      its(:client_order_id)       { should == attrs[:client_order_id]         }
      its(:seller_order_id)       { should == attrs[:seller_order_id]         }
      its(:state)                 { should == attrs[:order_state]             }
      its(:created_at)            { should == attrs[:order_time_gmt]          }
      its(:updated_at)            { should == attrs[:last_update_date]        }
      its(:total)                 { should == attrs[:total_order_amount].to_f }
      its(:cancelled_on)          { should == attrs[:date_cancelled_gmt]      }
      its(:flag_description)      { should == attrs[:flag_description]        }
      its(:reseller_id)           { should == attrs[:reseller_id]             }
      its(:buyer_email)           { should == attrs[:buyer_email]             }
      its(:email_opt_in)          { should == attrs[:email_opt_in]            }
      its(:shipping_instructions) { should == attrs[:shipping_info][:shipping_instructions]   }
      its(:estimated_ship_date)   { should == attrs[:shipping_info][:estimated_ship_date]     }
      its(:delivery_date)         { should == attrs[:shipping_info][:delivery_date]           }
      its(:buyer_ip_address)      { should == attrs[:buyer_ip_address]        }
      its(:transaction_notes)     { should == attrs[:transaction_notes]       }
      its(:custom_values)         { should == attrs[:custom_value_list]       }
      its(:status)                { should be_an OrderStatus                  }
      its(:payment)               { should be_a  Payment                      }
      its(:billing_address)       { should be_an Address                      }
      its(:shipping_address)      { should be_an Address                      }
      its(:shopping_cart)         { should be_a  ShoppingCart                 }

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

      it "sets @status to an OrderStatus object" do
        stub(OrderStatus).new
        Order.new(attrs)
        OrderStatus.should have_received.new(attrs[:order_status])
      end

      it "sets @payment to a Payment object" do
        stub(Payment).new
        Order.new(attrs)
        Payment.should have_received.new(attrs[:payment_info])
      end

      it "sets @billing_address to an Address object" do
        stub(Address).new
        Order.new(attrs)
        Address.should have_received.new(attrs[:billing_info])
      end

      it "sets @shipping_address to an Address object" do
        stub(Address).new
        Order.new(attrs)
        Address.should have_received.new(attrs[:shipping_info])
      end

      it "sets @shopping_cart to a ShoppingCart object" do
        stub(ShoppingCart).new
        Order.new(attrs)
        ShoppingCart.should have_received.new(attrs[:shopping_cart])
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
      before { @order = Order.new(:order_id => 14162751, :client_order_id => "14162751") }

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
