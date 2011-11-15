# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'bundler' do
	watch('Gemfile')
	watch(%r{^.+\.gemspec$})
end

guard 'yard', :stdout => '/dev/null', :stderr => '/dev/null' do
  watch(%r{lib/.+\.rb})
  watch('README.md')
  watch('LICENSE')
  watch('.yardopts')
end

guard 'rspec', :rvm => ['1.8.7@channeladvisor', '1.9.2@channeladvisor', '1.9.3@channeladvisor'], :run_all => {:cli => '-f p'}, :all_after_pass => false do
  watch(%r{^(spec/.+_spec\.rb)$})	{ |m| "#{m[1]}" }
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
