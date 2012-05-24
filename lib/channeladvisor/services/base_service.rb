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
              "ins0:DeveloperKey" => config(:developer_key),
              "ins0:Password"     => config(:password)
            }
          }
        end

        def config(attribute)
          ChannelAdvisor.configuration.send(attribute.to_sym)
        end
      end # self
    end # BaseService
  end # Services
end # ChannelAdvisor
