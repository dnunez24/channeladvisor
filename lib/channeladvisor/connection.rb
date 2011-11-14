module ChannelAdvisor
	class Connection
		def self.client(wsdl)
			@client ||= Savon::Client.new
			@client.wsdl.document = wsdl
			return @client
		end
	end
end
