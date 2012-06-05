module ChannelAdvisor
  module Services
    class AdminService < BaseService
      document "http://api.channeladvisor.com/ChannelAdvisorAPI/v6/AdminService.asmx?WSDL"

      class << self
        # Check authorization for and availability of the admin service
        #
        # @return [HTTPI::Response] HTTP response object containing the SOAP XML response
        def ping
          soap_response = client.request :ping do
            soap.header = soap_header
          end

          @last_request = client.http
          @last_response = soap_response
        end # ping

        # Request access to a ChannelAdvisor account
        #
        # @return [HTTPI::Response] HTTP response object containing the SOAP XML response
        def request_access(local_id)
          soap_response = client.request :request_access do
            soap.header = soap_header
            soap.body = {"localID" => local_id}
          end

          @last_request = client.http
          @last_response = soap_response
        end # request_access

        # Retrieve a list of account authorizations for the given developer key
        #
        # @return [HTTPI::Response] HTTP response object containing the SOAP XML response
        def get_authorization_list(local_id=nil)
          soap_response = client.request :get_authorization_list do
            soap.header = soap_header
            soap.body = {"localID" => local_id} if local_id
          end

          @last_request = client.http
          @last_response = soap_response
        end # get_authorization_list
      end # self
    end # AdminService
  end # Services
end # ChannelAdvisor