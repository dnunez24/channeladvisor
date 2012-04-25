require 'spec_helper'

describe ChannelAdvisor do
  describe ".configuration" do
    subject { ChannelAdvisor.configuration }

    it { should be_an_instance_of ChannelAdvisor::Configuration }
    it { should equal ChannelAdvisor.configuration }
  end

  describe ".configure" do
    it "yields the current configuration" do
      ChannelAdvisor.configure do |config|
        config.should equal ChannelAdvisor.configuration
      end
    end
  end
end