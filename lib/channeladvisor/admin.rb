module ChannelAdvisor
  class Admin < Base
    class << self
      attr_reader :last_response

      # Check authorization for and availability of the admin service
      #
      # @raise [ServiceFailure] If the SOAP response status is `Failure`
      # @raise [SOAPFault] If the service responds with a SOAP fault
      # @raise [HTTPError] If the service responds with an HTTP error
      # @return [Boolean] Returns `true` if the SOAP response status is `Success`
      def ping
        handle_errors do
          @last_response = service.ping
          result = @last_response[:ping_response][:ping_result]
          check_status_of result
        end
      end

      # Request access to a specific ChannelAdvisor account
      #
      # @param [Integer] local_id Local ID of the ChannelAdvisor account to which you are requesting access
      #
      # @raise [ServiceFailure] If the SOAP response status is `Failure`
      # @raise [SOAPFault] If the service responds with a SOAP fault
      # @raise [HTTPError] If the service responds with an HTTP error
      # @return [Boolean] Returns `true` if the SOAP response status is `Success`
      def request_access(local_id)
        handle_errors do
          @last_response = service.request_access(local_id)
          result = @last_response[:request_access_response][:request_access_result]
          check_status_of result
        end
      end

      # Retrieve a list of account authorizations for the given developer key and optional local ID
      #
      # @param [Integer] local_id Local ID of the ChannelAdvisor account for which you are checking authorization status
      #
      # @raise [ServiceFailure] If the SOAP response status is `Failure`
      # @raise [SOAPFault] If the service responds with a SOAP fault
      # @raise [HTTPError] If the service responds with an HTTP error
      # @return [Array<AccountAuthorization>] An array of account authorizations
      def get_authorization_list(local_id=nil)
        handle_errors do
          @last_response = service.get_authorization_list(local_id)
          result = @last_response[:get_authorization_list_response][:get_authorization_list_result]
          check_status_of result

          account_authorizations = []
          if result_data = result[:result_data]
            authorizations = result_data[:authorization_response]

            if authorizations.is_a? Array
              authorizations.each do |authorization|
                account_authorizations << AccountAuthorization.new(
                  authorization[:account_id],
                  authorization[:local_id],
                  authorization[:account_name],
                  authorization[:account_type],
                  authorization[:resource_name],
                  authorization[:status]
                )
              end
            else
              account_authorizations << AccountAuthorization.new(
                authorizations[:account_id],
                authorizations[:local_id],
                authorizations[:account_name],
                authorizations[:account_type],
                authorizations[:resource_name],
                authorizations[:status]
              )
            end
          end

          return account_authorizations
        end
      end

    private

      def service
        @service ||= Services::AdminService.new
      end

      def check_status_of(result)
        result[:status] == "Success" || raise(ServiceFailure, result[:message])
      end

      def handle_errors
        yield
      rescue Savon::SOAP::Fault => fault
        raise SOAPFault, fault
      rescue Savon::HTTP::Error => error
        raise HTTPError, error
      end
    end
  end # Admin
end # ChannelAdvisor
