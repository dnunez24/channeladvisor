require 'spec_helper'

module ChannelAdvisor
  module Services
    describe BaseService do
      its(:last_request)  { should be_nil }
      its(:last_response) { should be_nil }
    end
  end
end