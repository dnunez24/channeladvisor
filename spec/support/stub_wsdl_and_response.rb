module StubWsdlAndResponse

  def stub_wsdl(wsdl_url)
    service_name = underscore(wsdl_url.match(%r{v6\/(\w+)\.asmx})[1])

    FakeWeb.register_uri(
      :get,
      wsdl_url,
      :body => File.join(File.dirname(__FILE__), "../fixtures/wsdls/#{service_name}.xml")
    )
  end

  def stub_response(wsdl_url, method, data, status=nil)
    service_name = underscore(wsdl_url.match(%r{v6\/(\w+)\.asmx})[1])
    file_name = data.kind_of?(String) ? data : data.to_s

    response_xml = File.join(File.dirname(__FILE__), "../fixtures/responses/#{service_name}/#{method.to_s}/#{file_name}.xml")
    response = {:body => response_xml}
    response.update(:status => status) unless status.nil?

    FakeWeb.register_uri(
      :post,
      wsdl_url.gsub(/\?WSDL/, ''),
      response
    )
  end

private

  def underscore(string='')
    string.gsub!(/(.)([A-Z])/,'\1_\2').downcase!
  end

end