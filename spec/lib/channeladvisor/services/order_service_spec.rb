require 'spec_helper'

module ChannelAdvisor
	module Services
		describe OrderService do
			let(:service) { described_class.new }
			subject { service }

			shared_examples "a web service call" do
				its(:last_request) 	{ should be_an HTTPI::Request }
				its(:last_response) { should be_an HTTPI::Response }
			end

			describe "#ping" do
				use_vcr_cassette "responses/order_service/ping/success"
				before(:each) { service.ping }

				it_behaves_like "a web service call"

				context "when successful" do
					its("last_response.body") { should match /<PingResult>/ }
					its("last_response.body") { should match /<MessageCode>0<\/MessageCode>/ }
				end

				context "when unsuccessful" do
					use_vcr_cassette "responses/order_service/ping/failure"

					it "should raise a SOAP Fault error" do
						ChannelAdvisor.configure { |config| config.password = "wrong password" }
						expect { service.ping }.to raise_error Savon::SOAP::Fault
					end
				end
			end # ping

			describe "#get_order_list" do
				context "with no filters" do
					use_vcr_cassette "responses/order_service/get_order_list/no_filters_success"
					before(:each) { service.get_order_list }

					it_behaves_like "a web service call"

					context "when successful" do
						its("last_response.body") { should match /<GetOrderListResult>/ }
						its("last_response.body") { should match /<MessageCode>0<\/MessageCode>/ }
					end
				end

				context "with an order state filter" do
					use_vcr_cassette "responses/order_service/get_order_list/order_state_filter_success"

					it "sends a SOAP request with an order state filter" do
						service.get_order_list(:state => :cancelled)
						service.last_request.body.should match /<ord:OrderStateFilter>/				  
					end
				end
			end # get_order_list
		end # OrderService
	end # Services
end # ChannelAdvisor