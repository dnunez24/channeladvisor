require 'yaml'

def sensitive_data
  @sensitive_data ||= YAML.load_file("#{ENV["HOME"]}/.config/channeladvisor.yml")
end

RSpec.configure do |config|
  config.before(:each) do
    ChannelAdvisor.configure do |c|
      c.developer_key = sensitive_data["developer_key"]
      c.password      = sensitive_data["password"]
      c.account_id    = sensitive_data["account_ids"].first
    end
  end
end
