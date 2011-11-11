require 'spec_helper'

module ChannelAdvisor
  describe "Connection" do
    before(:each) do
      @channel_advisor = ChannelAdvisor::Connection.new(
        :developer_key => "11111111-1111-1111-1111-999999999999",
        :password => "mypassword",
        :account_id => "e83a0b1e-75f7-41e3-8aac-d8ff01f9d1ea"
      )
    end
    
    describe "#initialize" do
      it "assigns a value to the 'developer_key' attribute" do
        @channel_advisor.developer_key.should == "11111111-1111-1111-1111-999999999999"
        @channel_advisor.developer_key
      end

      it "assigns a value to the 'password' attribute" do
      	@channel_advisor.password.should == "mypassword"
      	@channel_advisor.password
      end

      it "assigns a value to the 'account_id' attribute" do
      	@channel_advisor.account_id.should == "e83a0b1e-75f7-41e3-8aac-d8ff01f9d1ea"
      	@channel_advisor.account_id
      end
    end

    describe "#client" do
      it "returns a SOAP client instance" do
        @channel_advisor.client.should be_an_instance_of Savon::Client
        @channel_advisor.client
      end

      it "memoizes the SOAP client" do
        client = @channel_advisor.client
        @channel_advisor.client.should equal client
        @channel_advisor.client
      end
    end
  end
end