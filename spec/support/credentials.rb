require 'yaml'

creds = YAML.load_file("#{Dir.home}/.config/channeladvisor.yml")

RSpec.configure do |config|
  config.before(:each) do
    ChannelAdvisor.configure do |c|
      c.account_id    = creds["account_id"]
      c.developer_key = creds["developer_key"]
      c.password      = creds["password"]
    end
  end
end
