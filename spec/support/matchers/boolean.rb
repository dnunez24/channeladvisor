RSpec::Matchers.define :be_a_boolean do |expected|
  match do |actual|
    [true, false].include? actual
  end

  description do |actual|
    "be a boolean"
  end

  failure_message_for_should do |actual|
    "expected #{actual} to be a boolean"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual} not to be a boolean"
  end
end