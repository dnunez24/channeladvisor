module ChannelAdvisor
  class Admin
    WSDL = "https://api.channeladvisor.com/ChannelAdvisorAPI/v6/AdminService.asmx?WSDL"

    NAMESPACES = {
      "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/"
    }

    AccountAuthorization = Struct.new(:account_id, :local_id, :account_name, :account_type, :resource_name, :status)

    # Checks authorization for and availability of the admin service
    #
    # @raise [Savon::SOAP::Fault] Raises an exception when the service returns a failure status
    # @return [String] Status message
    def self.ping
      response = client.request :ping do
        soap.xml do |xml|
          xml.soap :Envelope, Admin::NAMESPACES do
            xml.soap :Header do
              xml.web :APICredentials do
                xml.web :DeveloperKey, config(:developer_key)
                xml.web :Password, config(:password)
              end
            end
            xml.soap :Body do
              xml.web :Ping
            end
          end
        end
      end

      message = response.xpath('//web:ResultData', 'web' => 'http://api.channeladvisor.com/webservices/').text
      return message
    end

    # Allows you to request access to a specific CA Complete Account.
    #
    # @raise [ServiceFailure] Raises an exception when the service returns a failure status
    # @return [String] Status message
    def self.request_access(local_id)
      response = client.request :request_access do
        soap.xml do |xml|
          xml.soap :Envelope, Admin::NAMESPACES do
            xml.soap :Header do
              xml.web :APICredentials do
                xml.web :DeveloperKey, config(:developer_key)
                xml.web :Password, config(:password)
              end
            end
            xml.soap :Body do
              xml.web :RequestAccess do
                xml.web :localID, local_id
              end
            end
          end
        end
      end

      status = response.xpath('//web:Status', 'web' => 'http://api.channeladvisor.com/webservices/').text
      message = response.xpath('//web:ResultData', 'web' => 'http://api.channeladvisor.com/webservices/').text

      if status == "Failure"
        raise ServiceFailure, message
      else
        message
      end
    end

    # Retrieve a list of Account Authorizations for the developer key.
    #
    # @return [Array] Account Authorizations
    def self.get_authorization_list(local_id)
      response = client.request :request_access do
        soap.xml do |xml|
          xml.soap :Envelope, Admin::NAMESPACES do
            xml.soap :Header do
              xml.web :APICredentials do
                xml.web :DeveloperKey, config(:developer_key)
                xml.web :Password, config(:password)
              end
            end
            xml.soap :Body do
              xml.web :GetAuthorizationList do
                xml.web :localID, local_id
              end
            end
          end
        end
      end

      auths = []
      if result_data = response.body[:get_authorization_list_response][:get_authorization_list_result][:result_data]
        auths << AccountAuthorization.new(
          result_data[:authorization_response][:account_id],
          result_data[:authorization_response][:local_id],
          result_data[:authorization_response][:account_name],
          result_data[:authorization_response][:account_type],
          result_data[:authorization_response][:resource_name],
          result_data[:authorization_response][:status]
        )
        auths
      else
        auths
      end
    end

  private

    def self.client
      @client ||= Client.new WSDL
    end

    def self.config(attribute)
      ChannelAdvisor.configuration.send(attribute.to_sym)
    end
  end
end
