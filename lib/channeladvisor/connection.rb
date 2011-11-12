module ChannelAdvisor
	class Connection
		def self.client
			@client ||= Savon::Client.new
		end
	end
end