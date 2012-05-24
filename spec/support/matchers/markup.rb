RSpec::Matchers.define :match_valid_xml_body_for do |example_name|
  def example_path(example_name)
    service_name = described_class.name.split("::").last.gsub!(/(.)([A-Z])/, '\1_\2').downcase
    request_fixture_path = File.expand_path("../../../fixtures/requests/", __FILE__)
    File.join(request_fixture_path, service_name, "#{example_name}.xml")
  end

  def example_request(example_name)
    File.read(example_path(example_name))
  end

  def filter_request(request)
    request_body = request.body

    request_body.gsub!(sensitive_data['developer_key'], "$$DEVELOPER_KEY$$")
    request_body.gsub!(sensitive_data['password'], "$$PASSWORD$$")

    sensitive_data['account_ids'].each do |account_id|
      request_body.gsub!(account_id, "$$ACCOUNT_ID$$")
    end

    sensitive_data['local_ids'].each do |local_id|
      request_body.gsub!(local_id.to_s, "$$LOCAL_ID$$")
    end

    sensitive_data['account_names'].each do |account_name|
      request_body.gsub!(account_name, "$$ACCOUNT_NAME$$")
    end

    return request_body
  end

  match do |request|
    filter_request(request) == example_request(example_name)
  end

  description do
    "match the example request at: #{example_path(example_name)}"
  end

  failure_message_for_should do |request|
    "expected request to match:\n\n#{example_request(example_name)}\n\nbut received:\n\n#{filter_request(request)}"
  end

  failure_message_for_should_not do |request|
    "expected request not to match:\n\n#{example_request(example_name)}\n\nbut received:\n\n#{filter_request(request)}"
  end

  diffable
end