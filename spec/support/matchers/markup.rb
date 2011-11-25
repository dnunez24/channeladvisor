RSpec::Matchers.define :contain_nil_element do |element|
  match do |markup|
    markup =~ /<#{element} xsi:nil="true"><\/#{element}>/
  end

  failure_message_for_should do |markup|
    "expected markup to contain element #{element} with an xsi:nil attribute but received:\n#{markup}"
  end

  failure_message_for_should_not do |markup|
    "expected markup not to contain element #{element} with an xsi:nil attribute but received:\n#{markup}"
  end

  description do
    "contain element #{element} with an xsi:nil attribute"
  end
end

RSpec::Matchers.define :contain_element do |element|
  chain :with do |value|
    @value = value
  end

  match do |markup|
    if @value
      /<#{element}>(.*)<\/#{element}>/m.match markup do |m|
        m[1] =~ /#{Regexp.escape @value}/
      end
    else
      markup =~ /<#{element}>.*<\/#{element}>/m
    end
  end

  failure_message_for_should do |markup|
    if @value
      "expected markup to contain element '#{element}' with value '#{@value}' but received:\n#{markup}"
    else
      "expected markup to contain element '#{element}' but received:\n#{markup}"
    end
  end

  failure_message_for_should_not do |markup|
    if @value
      "expected markup not to contain element '#{element}' with value '#{@value}' but received:\n#{markup}"
    else
      "expected markup not to contain element '#{element}' but received:\n#{markup}"
    end
  end
end
