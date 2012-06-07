require 'spec_helper'

module ChannelAdvisor
  describe Admin do
    describe ".ping" do
      context "with a success status" do
        use_vcr_cassette "responses/admin/ping/success"

        it "records the last response" do
          Admin.ping
          Admin.last_response[:ping_response].should_not be_nil
        end

        it "returns true" do
          Admin.ping.should be_true
        end
      end

      context "with a failure status" do
        failure = {:message => "Service Unavailable"}
        use_vcr_cassette "responses/admin/ping/failure", :erb => failure

        it "raises a ServiceFailure error" do
          expect { Admin.ping }.to raise_error ServiceFailure, failure[:message]
        end
      end

      context "with a SOAP fault" do
        use_vcr_cassette "responses/soap_fault", :match_requests_on => [:method]
        
        it "raises a SOAP fault error" do
          ChannelAdvisor.configure { |c| c.developer_key = "WRONG" }
          expect { Admin.ping }.to raise_error SOAPFault, "Server was unable to process request. Authentication failed."
        end

        it "stores the SOAP fault code" do
          begin
            Admin.ping
          rescue SOAPFault => fault
            fault.code.should == "soap:Server"
          end
        end
      end

      context "with an HTTP error" do
        http_status = {:code => 500, :message => "Internal Server Error"}
        use_vcr_cassette "responses/http_error", :match_requests_on => [:method], :erb => http_status
       
        it "raises an HTTP error" do
          expect { Admin.ping }.to raise_error HTTPError, "Failed with HTTP error #{http_status[:code]}"
        end

        it "stores the HTTP status code" do
          begin
            Admin.ping
          rescue HTTPError => error
            error.code.should == http_status[:code]
          end
        end
      end
    end

    describe ".request_access" do
      let(:local_id) { sensitive_data["local_ids"].first }

      context "with a success status" do
        use_vcr_cassette "responses/admin/request_access/success"

        it "records the last response" do
          Admin.request_access(local_id)
          Admin.last_response[:request_access_response].should_not be_nil
        end

        it "returns true" do
          Admin.request_access(local_id).should be_true
        end
      end

      context "with a failure status" do
        use_vcr_cassette "responses/admin/request_access/failure"

        it "raises a ServiceFailure error" do
          expect { Admin.request_access(local_id) }.to raise_error ServiceFailure, "An Authorization for the specified ID [$$LOCAL_ID$$] already exists!"
        end
      end

      context "with a SOAP fault" do
        use_vcr_cassette "responses/soap_fault", :match_requests_on => [:method]
        
        it "raises a SOAP fault error" do
          ChannelAdvisor.configure { |c| c.developer_key = "WRONG" }
          expect { Admin.request_access(local_id) }.to raise_error SOAPFault, "Server was unable to process request. Authentication failed."
        end

        it "stores the SOAP fault code" do
          begin
            Admin.request_access(local_id)
          rescue SOAPFault => fault
            fault.code.should == "soap:Server"
          end
        end
      end

      context "with an HTTP error" do
        http_status = {:code => 500, :message => "Internal Server Error"}
        use_vcr_cassette "responses/http_error", :match_requests_on => [:method], :erb => http_status
       
        it "raises an HTTP error" do
          expect { Admin.request_access(local_id) }.to raise_error HTTPError, "Failed with HTTP error #{http_status[:code]}"
        end

        it "stores the HTTP status code" do
          begin
            Admin.request_access(local_id)
          rescue HTTPError => error
            error.code.should == http_status[:code]
          end
        end
      end
    end

    describe ".get_authorization_list" do
      let(:local_id) { sensitive_data["local_ids"].first }

      context "with a success status" do
        use_vcr_cassette "responses/admin/get_authorization_list/success"

        it "records the last response" do
          Admin.get_authorization_list(local_id)
          Admin.last_response[:get_authorization_list_response].should_not be_nil
        end

        context "with no authorizations" do
          use_vcr_cassette "responses/admin/get_authorization_list/no_authorizations", :exclusive => true

          it "should return an array" do
            Admin.get_authorization_list(local_id).should be_an Array
          end

          it "returns an empty array" do
            Admin.get_authorization_list(local_id).should have(0).items
          end
        end

        context "with one authorization" do
          use_vcr_cassette "responses/admin/get_authorization_list/one_authorization", :exclusive => true

          it "should be an array with one element" do
            Admin.get_authorization_list(local_id).should have(1).item
          end

          it "should have an array containing an AccountAuthorization object" do
            Admin.get_authorization_list(local_id).first.should be_an AccountAuthorization
          end
        end

        context "with two authorizations" do
          use_vcr_cassette "responses/admin/get_authorization_list/two_authorizations", :exclusive => true

          it "should be an array with two elements" do
            Admin.get_authorization_list.should have(2).items
          end

          it "should have an array containing AccountAuthorization objects" do
            account_authorizations = Admin.get_authorization_list(local_id)
            account_authorizations.each do |account_authorization|
              account_authorization.should be_an AccountAuthorization
            end
          end
        end
      end

      context "with a failure status" do
        use_vcr_cassette "responses/admin/get_authorization_list/failure"

        it "raises a ServiceFailure error" do
          expect { Admin.get_authorization_list("WRONG") }.to raise_error ServiceFailure, "Input string was not in a correct format."
        end
      end

      context "with a SOAP fault" do
        use_vcr_cassette "responses/soap_fault", :match_requests_on => [:method]
        
        it "raises a SOAP fault error" do
          ChannelAdvisor.configure { |c| c.developer_key = "WRONG" }
          expect { Admin.get_authorization_list(local_id) }.to raise_error SOAPFault, "Server was unable to process request. Authentication failed."
        end

        it "stores the SOAP fault code" do
          begin
            Admin.get_authorization_list(local_id)
          rescue SOAPFault => fault
            fault.code.should == "soap:Server"
          end
        end
      end

      context "with an HTTP error" do
        http_status = {:code => 500, :message => "Internal Server Error"}
        use_vcr_cassette "responses/http_error", :match_requests_on => [:method], :erb => http_status, :erb => http_status
       
        it "raises an HTTP error" do
          expect { Admin.get_authorization_list(local_id) }.to raise_error HTTPError, "Failed with HTTP error #{http_status[:code]}"
        end

        it "stores the HTTP status code" do
          begin
            Admin.get_authorization_list(local_id)
          rescue HTTPError => error
            error.code.should == http_status[:code]
          end
        end
      end
    end # get_authorization_list
  end # Admin
end # ChannelAdvisor
