module ChannelAdvisor
  class Error < StandardError; end

  class SOAPFault < Error
    attr_reader :code

    def initialize(fault_obj)
      fault = fault_obj.to_hash[:fault]
      @code = fault[:faultcode]
      message = fault[:faultstring]

      super(message)
    end
  end

  class HTTPError < Error
    attr_reader :code

    def initialize(error_obj)
      error = error_obj.to_hash
      @code = error[:code]
      message = "Failed with HTTP error #{@code}"

      super(message)
    end
  end

  class ServiceFailure < Error; end
end

