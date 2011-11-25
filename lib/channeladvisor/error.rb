module ChannelAdvisor
  class Error < StandardError; end
  class ServiceFailure < Error; end
  class SoapFault < Error; end
  class HttpError < Error; end
end
