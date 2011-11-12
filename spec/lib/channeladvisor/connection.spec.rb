require 'spec_helper'

# module ChannelAdvisor
#   describe Connection do
#     describe :configure do
#       before(:all) do
#         ChannelAdvisor::Connection.configure do |config|
#           config.account_id = "e83a0b1e-75f7-41e3-8aac-d8ff01f9d1ea"
#           config.developer_key = "11111111-1111-1111-1111-999999999999"
#           config.password = "mypassword"
#         end
#       end

#       it "configures the account_id value" do
#         ChannelAdvisor::Connection.account_id.should == "e83a0b1e-75f7-41e3-8aac-d8ff01f9d1ea"
#         ChannelAdvisor::Connection.account_id
#       end

#       it "configures the developer_key value" do
#         ChannelAdvisor::Connection.developer_key.should == "11111111-1111-1111-1111-999999999999"
#         ChannelAdvisor::Connection.developer_key
#       end

#       it "configures the password value" do
#         ChannelAdvisor::Connection.password.should == "mypassword"
#         ChannelAdvisor::Connection.password
#       end
#     end

#     describe :client do
#       it "returns a SOAP client instance" do
#         ChannelAdvisor::Connection.client.should be_an_instance_of Savon::Client
#         ChannelAdvisor::Connection.client
#       end

#       it "memoizes the SOAP client" do
#         client = ChannelAdvisor::Connection.client
#         ChannelAdvisor::Connection.client.should equal client
#         ChannelAdvisor::Connection.client
#       end
#     end
#   end
# end