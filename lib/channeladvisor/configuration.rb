module ChannelAdvisor
	class Configuration
		attr_accessor :account_id, :developer_key, :password

		def initialize
			@account_id = nil
			@developer_key = nil
			@password = nil
		end
	end
end
