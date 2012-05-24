require 'spec_helper'

module ChannelAdvisor
  module Services
    describe AdminService do
      subject { AdminService }
      let(:local_id) { sensitive_data["local_ids"].first }

      describe "#ping" do
        context "when successful" do
          use_vcr_cassette "responses/admin_service/ping/success"
          before(:each) { AdminService.ping }

          its(:last_request)  { should match_valid_xml_body_for :ping }
          its(:last_request)  { should be_an HTTPI::Request }
          its(:last_response) { should be_a Savon::SOAP::Response }
        end

        context "when unsuccessful" do
          use_vcr_cassette "responses/admin_service/ping/failure"
          before(:each) do
            ChannelAdvisor.configure { |config| config.password = "wrong password" }
          end

          it "should raise a SOAP Fault error" do
            expect { AdminService.ping }.to raise_error Savon::SOAP::Fault
          end
        end
      end # ping
        
      describe "#request_access" do
        context "when successful" do
          use_vcr_cassette "responses/admin_service/request_access/success"
          before(:each) { AdminService.request_access(local_id) }

          its(:last_request)  { should match_valid_xml_body_for :request_access }
          its(:last_request)  { should be_an HTTPI::Request }
          its(:last_response) { should be_a Savon::SOAP::Response }
        end
      end # request_access

      describe "#get_authorization_list" do
        context "without Local ID" do
          use_vcr_cassette "responses/admin_service/get_authorization_list/without_local_id/success"
          before(:each) { AdminService.get_authorization_list }

          its(:last_request)  { should match_valid_xml_body_for :get_authorization_list }
          its(:last_request)  { should be_an HTTPI::Request }
          its(:last_response) { should be_a Savon::SOAP::Response }
        end

        context "with Local ID" do
          context "when successful" do
            use_vcr_cassette "responses/admin_service/get_authorization_list/with_local_id/success"
            before(:each) { AdminService.get_authorization_list(local_id) }

            its(:last_request)  { should match_valid_xml_body_for :get_authorization_list_with_local_id }
            its(:last_request)  { should be_an HTTPI::Request }
            its(:last_response) { should be_a Savon::SOAP::Response }
          end
        end
      end # get_authorization_list
    end # AdminService
  end # Services
end # ChannelAdvisor