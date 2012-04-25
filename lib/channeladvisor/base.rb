module ChannelAdvisor
  class Base
    # class << self
      
    # private

    #   def soap_header(envelope)
    #     envelope.soap :Header do |header|
    #       header.web :APICredentials do |api_credentials|
    #         api_credentials.web :DeveloperKey, config(:developer_key)
    #         api_credentials.web :Password, config(:password)
    #       end
    #     end
    #   end

    #   def client
    #     @client ||= Client.new(const_get(:WSDL))
    #   end

    #   def config(attribute)
    #     ChannelAdvisor.configuration.send(attribute.to_sym)
    #   end
    # end # self
  end # Base
end # ChannelAdvisor