require 'spec_helper'

module ChannelAdvisor
  describe "Connection" do
    describe "#initialize" do
      it "assigns a value to the developer_key attribute" do
        channel_advisor = ChannelAdvisor::Connection.new :developer_key => "11111111-1111-1111-1111-999999999999"
        channel_advisor.developer_key.should == "11111111-1111-1111-1111-999999999999"
        channel_advisor.developer_key
      end

      it "assigns a value to the password attribute" do
      	channel_advisor = ChannelAdvisor::Connection.new :password => "mypassword"
      	channel_advisor.password.should == "mypassword"
      	channel_advisor.password
      end

      it "assigns a value to the account_id attribute" do
      	channel_advisor = ChannelAdvisor::Connection.new :account_id => "e83a0b1e-75f7-41e3-8aac-d8ff01f9d1ea"
      	channel_advisor.account_id.should == "e83a0b1e-75f7-41e3-8aac-d8ff01f9d1ea"
      	channel_advisor.account_id
      end
    end
  end
end