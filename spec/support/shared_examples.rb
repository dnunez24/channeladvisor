shared_examples "a web service call" do
  its(:last_request) 	{ should be_an HTTPI::Request }
  its(:last_response) { should be_an HTTPI::Response }
end
