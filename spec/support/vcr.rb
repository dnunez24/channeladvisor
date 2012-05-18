require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('../../fixtures', __FILE__)
  config.hook_into :fakeweb
  config.configure_rspec_metadata!
  
  config.register_request_matcher :soap_action do |recorded, current|
    recorded.headers["soapaction"] == current.headers["soapaction"]
  end

  config.default_cassette_options = {
    :record => :once,
    :match_requests_on => [:method, :uri, :soap_action],
    :erb => true
  }

  config.filter_sensitive_data("$$DEVELOPER_KEY$$") { sensitive_data['developer_key'] }
  config.filter_sensitive_data("$$PASSWORD$$")      { sensitive_data['password'] }

  config.before_record do |interaction|
    sensitive_data['account_ids'].each do |account_id|
      interaction.filter!(account_id, "$$ACCOUNT_ID$$")
    end

    sensitive_data['local_ids'].each do |local_id|
      interaction.filter!(local_id.to_s, "$$LOCAL_ID$$")
    end

    sensitive_data['account_names'].each do |account_name|
      interaction.filter!(account_name, '$$ACCOUNT_NAME$$')
    end
  end
end

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
end