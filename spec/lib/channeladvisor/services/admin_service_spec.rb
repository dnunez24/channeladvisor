require 'spec_helper'

module ChannelAdvisor
  module Services
    describe AdminService do
      let(:service) { described_class.new }
      subject { service }

      shared_examples "a web service call" do
        its(:last_request) 	{ should be_an HTTPI::Request }
        its(:last_response) { should be_an HTTPI::Response }
      end

      describe "#ping" do
        use_vcr_cassette "responses/admin_service/ping/success"
        before(:each) { service.ping }

        it_behaves_like "a web service call"

        context "when successful" do
          its("last_response.body") { should match /<PingResult>/ }
          its("last_response.body") { should match /<MessageCode>0<\/MessageCode>/ }
        end

        context "when unsuccessful" do
          use_vcr_cassette "responses/admin_service/ping/failure"

          it "should raise a SOAP Fault error" do
            ChannelAdvisor.configure { |config| config.password = "wrong password" }
            expect { service.ping }.to raise_error Savon::SOAP::Fault
          end
        end
      end # ping

      describe "#request_access" do
        let(:local_id) { 0000000 }

        use_vcr_cassette "responses/admin_service/request_access/success"
        before(:each) { service.request_access(local_id) }

        context "when successful" do
          its("last_response.body") { should match /<RequestAccessResult>/ }
          its("last_response.body") { should match /<MessageCode>0<\/MessageCode>/ }
        end

        # FIXME: need to add failure VRC cassette for AdminService #request_access
        # context "when unsuccessful" do
        #   use_vcr_cassette "responses/admin_service/request_access/failure"
        # 
        #   its("last_response.body") { should match /<RequestAccessResult>/ }
        #   its("last_response.body") { should match /<MessageCode>12<\/MessageCode>/ }
        # end
      end # request_access

      describe "#get_authorization_list" do
        let(:local_id) { 00000000 }

        use_vcr_cassette "responses/admin_service/get_authorization_list/success"
        before(:each) { service.get_authorization_list(local_id) }

        context "when successful" do
          its("last_response.body") { should match /<GetAuthorizationListResult>/ }
          its("last_response.body") { should match /<MessageCode>0<\/MessageCode>/ }
        end

        # FIXME: need to add failure VRC cassette for AdminService #get_authorization_list
        # context "when unsuccessful" do
        #   use_vcr_cassette "responses/admin_service/get_authorization_list/failure"
        # 
        #   its("last_response.body") { should match /<GetAuthorizationListResult>/ }
        #   its("last_response.body") { should match /<MessageCode>12<\/MessageCode>/ }
        # end
      end # request_access
    end
  end
end