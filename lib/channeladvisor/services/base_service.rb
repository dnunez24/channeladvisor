module ChannelAdvisor
  module Services
    class BaseService
      attr_reader :last_request, :last_response

    private

      def soap_header(envelope)
        envelope.soap :Header do |header|
          header.web :APICredentials do |api_credentials|
            api_credentials.web :DeveloperKey, config(:developer_key)
            api_credentials.web :Password, config(:password)
          end
        end
      end

      def client
        @client ||= ChannelAdvisor::Client.new(self.class::WSDL)
      end

      def config(attribute)
        ChannelAdvisor.configuration.send(attribute.to_sym)
      end

      def xsi_nil(value)
        value.nil? ? {"xsi:nil" => true} : value
      end
    end # BaseService
  end # Services
end # ChannelAdvisor
