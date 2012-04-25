require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('../../fixtures', __FILE__)
  config.default_cassette_options = {
    :record => :new_episodes,
    :match_requests_on => [:method, :uri, :headers, :body],
    :erb => true
  }
  config.hook_into :fakeweb
  config.configure_rspec_metadata!
  config.filter_sensitive_data("$$ACCOUNT_ID$$")    { ChannelAdvisor.configuration.account_id }
  config.filter_sensitive_data("$$DEVELOPER_KEY$$") { ChannelAdvisor.configuration.developer_key }
  config.filter_sensitive_data("$$PASSWORD$$")      { ChannelAdvisor.configuration.password }

  config.filter_sensitive_data("$$LOCAL_ID$$")       { "00000000" }
  config.filter_sensitive_data("$$ACCOUNT_NAME$$")   { "ACME" }
end

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
end