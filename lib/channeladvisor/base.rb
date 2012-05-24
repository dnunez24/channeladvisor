module ChannelAdvisor
  class Base

  private

    def arrayify(data)
      self.class.arrayify(data)
    end

    def check_status_of(result)
      self.class.check_status_of result
    end

    def handle_errors
      self.class.handle_errors { yield }
    end

    def self.arrayify(data)
      data.is_a?(Array) ? data : [data]
    end

    def self.check_status_of(result)
      result[:status] == "Success" || raise(ServiceFailure, result[:message])
    end

    def self.handle_errors
      yield
    rescue Savon::SOAP::Fault => fault
      raise SOAPFault.new(fault)
    rescue Savon::HTTP::Error => error
      raise HTTPError.new(error)
    end
  end # Base
end # ChannelAdvisor