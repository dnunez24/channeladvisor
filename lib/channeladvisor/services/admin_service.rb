module ChannelAdvisor
  module Services
    class AdminService < BaseService
      WSDL = "https://api.channeladvisor.com/ChannelAdvisorAPI/v6/AdminService.asmx?WSDL"

      NAMESPACES = {
        "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
        "xmlns:web" => "http://api.channeladvisor.com/webservices/"
      }

      # Checks authorization for and availability of the admin service
      #
      # @raise [ServiceFailure] Raises an exception when the service returns a failure status
      # @return [String] Status message
      def ping
        soap_response = client.request :ping do
          soap.xml do |xml|
            xml.soap :Envelope, NAMESPACES do |envelope|
              soap_header(envelope)
              envelope.soap :Body do |body|
                body.web :Ping
              end
            end
          end
        end

        # TODO: Handle Savon::SOAP::Response faults and HTTP errors

        @last_request = client.http
        @last_response = soap_response.http
      end # ping

      # Allows you to request access to a specific CA Complete Account.
      #
      # @raise [ServiceFailure] Raises an exception when the service returns a failure status
      # @return [Object] SOAP HTTP response
      def request_access(local_id)
        soap_response = client.request :request_access do
          soap.xml do |xml|
            xml.soap :Envelope, NAMESPACES do |envelope|
              soap_header(envelope)
              envelope.soap :Body do |body|
                body.web :RequestAccess do |request_access|
                  request_access.web :localID, local_id
                end
              end
            end
          end
        end

        # TODO: Handle Savon::SOAP::Response faults and HTTP errors

        @last_request = client.http
        @last_response = soap_response.http
      end # request_access

      # Retrieve a list of Account Authorizations for the developer key.
      #
      # @return [Object] SOAP HTTP response
      def get_authorization_list(local_id)
        soap_response = client.request :get_authorization_list do
          soap.xml do |xml|
            xml.soap :Envelope, NAMESPACES do |envelope|
              soap_header(envelope)
              envelope.soap :Body do |body|
                body.web :GetAuthorizationList do |get_authorization_list|
                  get_authorization_list.web :localID, local_id
                end
              end
            end
          end
        end

        # TODO: Handle Savon::SOAP::Response faults and HTTP errors

        @last_request = client.http
        @last_response = soap_response.http
      end # get_authorization_list
    end
  end
end