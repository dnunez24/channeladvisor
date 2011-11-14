# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :version => 2 do
  watch(%r{^spec/.+\.spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}.spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

guard 'bundler' do
	watch('Gemfile')
	watch(%r{^.+\.gemspec$})
end