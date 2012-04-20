require 'spec_helper'

describe ChannelAdvisor do
  describe ".configure" do
  	describe "account_id" do
	    it "sets the account ID" do
	      ChannelAdvisor.configure { |config| config.account_id = "e83a0b1e-75f7-41e3-8aac-d8ff01f9d1ea" }
        ChannelAdvisor.configuration.account_id.should == "e83a0b1e-75f7-41e3-8aac-d8ff01f9d1ea"
	    end
  	end

  	describe "developer_key" do
  		it "sets the developer ID" do
	      ChannelAdvisor.configure { |config| config.developer_key = "11111111-1111-1111-1111-999999999999" }
        ChannelAdvisor.configuration.developer_key.should == "11111111-1111-1111-1111-999999999999"
  		end
  	end

  	describe "password" do
  	  it "sets the password" do
	      ChannelAdvisor.configure { |config| config.password = "mypassword" }
        ChannelAdvisor.configuration.password.should == "mypassword"
  	  end
  	end
  end
end