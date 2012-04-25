require 'spec_helper'

module ChannelAdvisor
  describe Admin, "AccountAuthorization" do
  #   context "a new instance" do
  #     let(:account_authorization) do
  #       ChannelAdvisor::Admin::AccountAuthorization.new(
  #         '00000000-1111-2222-3333-444444444444',
  #         1234567890,
  #         'ACME',
  #         'merchant',
  #         '/channeladvisorapi',
  #         'Enabled'
  #       )
  #     end

  #     describe '#account_id' do
  #       subject { account_authorization.account_id }

  #       it { should == '00000000-1111-2222-3333-444444444444' }
  #     end

  #     describe '#local_id' do
  #       subject { account_authorization.local_id }

  #       it { should == 1234567890 }
  #     end

  #     describe '#account_name' do
  #       subject { account_authorization.account_name }

  #       it { should == 'ACME' }
  #     end

  #     describe '#account_type' do
  #       subject { account_authorization.account_type }

  #       it { should == 'merchant' }
  #     end

  #     describe '#resource_name' do
  #       subject { account_authorization.resource_name }

  #       it { should == '/channeladvisorapi' }
  #     end

  #     describe '#status' do
  #       subject { account_authorization.status }

  #       it { should == 'Enabled' }
  #     end
  #   end
  # end
  
  # describe Admin, ".ping" do
  #   let(:wsdl) { ChannelAdvisor::Admin::WSDL }

  #   before(:each) do
  #     stub_wsdl(wsdl)
  #     stub_response(wsdl, :ping, data)
  #   end

  #   subject { ChannelAdvisor::Admin.ping }

  #   context "when successful" do
  #     let(:data) { :success }

  #     it { should == 'OK' }
  #   end

  #   context "when unsuccessful" do
  #     let(:data) { :failure }

  #     it "raises a Savon SOAP fault" do
  #       expect { subject }.to raise_error Savon::SOAP::Fault
  #     end
  #   end
  # end # Admin.ping

  # describe Admin, ".request_access" do
  #   let(:wsdl) { ChannelAdvisor::Admin::WSDL }

  #   before(:each) do
  #     stub_wsdl(wsdl)
  #     stub_response(wsdl, :request_access, data)
  #   end

  #   subject { ChannelAdvisor::Admin.request_access(1234567890) }

  #   context "when successful" do
  #     let(:data) { :success }

  #     it { should be_true }
  #   end

  #   context "when unsuccessful" do
  #     let(:data) { :failure }

  #     it "raises a Savon SOAP fault" do
  #       expect { subject }.to raise_error ServiceFailure
  #     end
  #   end
  # end # Admin.request_access

  # describe Admin, ".get_authorization_list" do
  #   let(:wsdl) { ChannelAdvisor::Admin::WSDL }

  #   before(:each) do
  #     stub_response(wsdl, :get_authorization_list, data)
  #     stub_wsdl(wsdl)
  #   end

  #   subject { ChannelAdvisor::Admin.get_authorization_list(1234567890) }

  #   context "when successful" do
  #     let(:data) { :success }

  #     it { should_not be_empty }
  #   end

  #   context "when unsuccessful" do
  #     let(:data) { :failure }

  #     it { should be_empty }
  #   end
  end # Admin.get_authorization_list
end # ChannelAdvisor
