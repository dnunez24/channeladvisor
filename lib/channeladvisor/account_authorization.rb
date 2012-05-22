module ChannelAdvisor
  class AccountAuthorization
    attr_reader :account_id, :local_id, :account_name, :account_type, :resource_name, :status

    def initialize(account_id, local_id, account_name, account_type, resource_name, status)
      @account_id     = account_id
      @local_id       = local_id
      @account_name   = account_name
      @account_type   = account_type
      @resource_name  = resource_name
      @status         = status
    end
  end
end