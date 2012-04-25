module ChannelAdvisor
  class Admin < Base
    AccountAuthorization = Struct.new(:account_id, :local_id, :account_name, :account_type, :resource_name, :status)

    # Checks authorization for and availability of the admin service
    #
    # @raise [Savon::SOAP::Fault] Raises an exception when the service returns a failure status
    # @return [String] Status message
    def self.ping
      response = admin_service.ping

      status = response.xpath('//web:Status', 'web' => 'http://api.channeladvisor.com/webservices/').text
      message = response.xpath('//web:ResultData', 'web' => 'http://api.channeladvisor.com/webservices/').text

      if status == "Failure"
        raise ServiceFailure, message
      else
        message
      end
    end

    # Allows you to request access to a specific CA Complete Account.
    #
    # @raise [ServiceFailure] Raises an exception when the service returns a failure status
    # @return [String] Status message
    def self.request_access(local_id)
      response = admin_service.request_access(local_id)

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
      response = admin_service.get_authorization_list(local_id)

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

    def self.admin_service
      @admin_service ||= Services::AdminService.new
    end
  end
end
