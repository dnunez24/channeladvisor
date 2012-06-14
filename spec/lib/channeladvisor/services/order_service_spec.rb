require 'spec_helper'

module ChannelAdvisor
	module Services
		describe OrderService do
			subject { OrderService }
			
			describe "#ping" do
				context "when successful" do
					use_vcr_cassette "responses/order_service/ping/success"
					before(:each) { OrderService.ping }

	        its(:last_request)  { should match_valid_xml_body_for :ping }
	        its(:last_request)  { should be_an HTTPI::Request }
	        its(:last_response) { should be_a Savon::SOAP::Response }
				end

				context "when unsuccessful" do
					use_vcr_cassette "responses/order_service/ping/failure"

					it "should raise a SOAP Fault error" do
						ChannelAdvisor.configure { |config| config.password = "wrong password" }
						expect { OrderService.ping }.to raise_error Savon::SOAP::Fault
					end
				end
			end # ping

			describe "#get_order_list" do
				context "without order criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/without_order_criteria"
					before(:each) { OrderService.get_order_list }

	        its(:last_request)  { should be_an HTTPI::Request }
	        its(:last_response) { should be_a Savon::SOAP::Response }
				
					it "sends a valid SOAP request with no order criteria" do
						OrderService.last_request.should match_valid_xml_body_for 'get_order_list/without_order_criteria'
					end
				end

				context "with created from date criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_created_from_date"

				  it "sends a valid SOAP request with the created from date" do
				  	order_criteria = {:created_from => DateTime.new(2012,05,14)}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_created_from_date'
				  end
				end

				context "with created to date criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_created_to_date"

				  it "sends a valid SOAP request with the created to date" do
				  	order_criteria = {:created_to => DateTime.new(2012,05,15)}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_created_to_date'
				  end
				end

				context "with updated from date criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_updated_from_date"

					it "sends a valid SOAP request with the updated from date" do
					  order_criteria = {:updated_from => DateTime.new(2012,05,14)}
					  OrderService.get_order_list(order_criteria)
						OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_updated_from_date'				  
					end
				end

				context "with updated to date criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_updated_to_date"

					it "sends a valid SOAP request with the updated to date" do
					  order_criteria = {:updated_to => DateTime.new(2012,05,15)}
					  OrderService.get_order_list(order_criteria)
						OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_updated_to_date'				  
					end
				end

				context "with join dates criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_join dates"
				  
				  it "sends a valid SOAP request with the join dates" do
				  	order_criteria = {
				  		:created_from => DateTime.new(2012,05,14),
				  		:created_to => DateTime.new(2012,05,15),
				  		:updated_from => DateTime.new(2012,05,14),
				  		:updated_to => DateTime.new(2012,05,15),
				  		:join_dates => true
				  	}
				    
				    OrderService.get_order_list(order_criteria)
				    OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_join_dates'
				  end
				end

				context "with detail level criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_detail_level"

				  it "sends a valid SOAP request with a detail level" do
				  	order_criteria = {:detail_level => "Low"}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_detail_level'
				  end
				end

				context "with export state criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_export_state"

				  it "sends a valid SOAP request with an export state" do
				  	order_criteria = {:export_state => "NotExported"}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_export_state'
				  end
				end

				context "with one Order ID" do
					use_vcr_cassette "responses/order_service/get_order_list/with_one_order_id"

					it "sends a valid SOAP request with one Order ID" do
						order_criteria = {:order_ids => [14162751]}
						OrderService.get_order_list(order_criteria)
						OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_one_order_id'
					end
				end

				context "with two Order IDs" do
					use_vcr_cassette "responses/order_service/get_order_list/with_two_order_ids"

					it "sends a valid SOAP request with two Order IDs" do
						order_criteria = {:order_ids => [14162751, 14161613]}
						OrderService.get_order_list(order_criteria)
						OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_two_order_ids'
					end
				end

				context "with one Client ID" do
					use_vcr_cassette "responses/order_service/get_order_list/with_one_client_order_id"

					it "sends a valid SOAP request with one Client ID" do
						order_criteria = {:client_order_ids => ['ABCD1234']}
						OrderService.get_order_list(order_criteria)
						OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_one_client_order_id'
					end
				end

				context "with two Client IDs" do
					use_vcr_cassette "responses/order_service/get_order_list/with_two_client_order_ids"

					it "sends a valid SOAP request with one Client ID" do
						order_criteria = {:client_order_ids => ['ABCD1234', 'EFGH5678']}
						OrderService.get_order_list(order_criteria)
						OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_two_client_order_ids'
					end
				end

				context "with order state criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_order_state_filter"

				  it "sends a valid SOAP request with an order state" do
				  	order_criteria = {:state => "Active"}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_order_state_filter'
				  end
				end

				context "with payment status criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_payment_status_filter"

				  it "sends a valid SOAP request with a payment status" do
				  	order_criteria = {:payment_status => "NoChange"}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_payment_status_filter'
				  end
				end

				context "with checkout status criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_checkout_status_filter"

				  it "sends a valid SOAP request with an checkout status" do
				  	order_criteria = {:checkout_status => "NoChange"}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_checkout_status_filter'
				  end
				end

				context "with shipping status criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_shipping_status_filter"

				  it "sends a valid SOAP request with a shipping status" do
				  	order_criteria = {:shipping_status => "NoChange"}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_shipping_status_filter'
				  end
				end

				context "with refund status criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_refund_status_filter"

				  it "sends a valid SOAP request with an refund status" do
				  	order_criteria = {:refund_status => "NoChange"}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_refund_status_filter'
				  end
				end

				context "with distribution center criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_distribution_center_code"

				  it "sends a valid SOAP request with a distribution center code" do
				  	order_criteria = {:distribution_center => "ABC"}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_distribution_center_code'
				  end
				end

				context "with page number criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_page_number_filter"

				  it "sends a valid SOAP request with a page number" do
				  	order_criteria = {:page_number => 1}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_page_number_filter'
				  end
				end

				context "with page size criteria" do
					use_vcr_cassette "responses/order_service/get_order_list/with_page_size"

				  it "sends a valid SOAP request with a page size" do
				  	order_criteria = {:page_size => 20}
				  	OrderService.get_order_list(order_criteria)
				  	OrderService.last_request.should match_valid_xml_body_for 'get_order_list/with_page_size'
				  end
				end
			end # get_order_list

			describe "#set_orders_export_status" do
				context "with one Client Order ID" do
					use_vcr_cassette "responses/order_service/set_orders_export_status/with_one_client_order_id"
					before(:each) do
				  	client_order_ids = ["ABCD1234"]
				    OrderService.set_orders_export_status(client_order_ids, true)
					end

				  its(:last_request)  { should be_an HTTPI::Request }
					its(:last_response) { should be_an Savon::SOAP::Response }

				  it "sends a valid SOAP request with one Client Order ID" do
				    OrderService.last_request.should match_valid_xml_body_for "set_orders_export_status/with_one_client_order_id"
				  end
				end

				context "with two Client Order IDs" do
					use_vcr_cassette "responses/order_service/set_orders_export_status/with_two_client_order_id"

				  it "sends a valid SOAP request with two Client Order IDs" do
				    client_order_ids = ["ABCD1234", "EFGH5678"]
				    OrderService.set_orders_export_status(client_order_ids, true)
				    OrderService.last_request.should match_valid_xml_body_for "set_orders_export_status/with_two_client_order_ids"
				  end
				end
			end # set_orders_export_status
		end # OrderService
	end # Services
end # ChannelAdvisor