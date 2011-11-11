module ChannelAdvisor
	class Connection
		attr_accessor :developer_key, :password, :account_id

		def initialize(credentials = {})
			@developer_key = credentials[:developer_key]
			@password = credentials[:password]
			@account_id = credentials[:account_id]
		end
	end
end