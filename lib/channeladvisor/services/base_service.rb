module ChannelAdvisor
  module Services
    class BaseService
      extend Savon::Model

      class << self
        attr_reader :last_request, :last_response

      private

        def soap_header
          {
            "ins0:APICredentials" => {
              "ins0:DeveloperKey" => creds(:developer_key),
              "ins0:Password"     => creds(:password)
            }
          }
        end

        def creds(attribute)
          ChannelAdvisor.configuration.send(attribute.to_sym)
        end
      end # self
    end # BaseService
  end # Services
end # ChannelAdvisor
