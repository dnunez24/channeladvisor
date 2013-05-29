require 'yaml'

def sensitive_data
  unless defined?(@sensitive_data)
    file_path         = File.join(ENV["HOME"], '.config/channeladvisor.yml')
    sensitive_data    = YAML.load_file(file_path) if File.exists?(file_path)
    @sensitive_data   = sensitive_data || {
      'account_ids'   => %w($$ACCOUNT_ID$$),
      'developer_key' => '$$DEVELOPER_KEY$$',
      'password'      => '$$PASSWORD$$',
      'local_ids'     => %w($$LOCAL_ID$$),
      'account_names' => %w($$ACCOUNT_NAME$$)
    }
  end

  return @sensitive_data
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
