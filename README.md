ChannelAdvisor [![Build Status](https://secure.travis-ci.org/dnunez24/channeladvisor.png)](http://travis-ci.org/dnunez24/channeladvisor)
==============

Ruby wrapper for the SOAP API provided by ChannelAdvisor.

Install
-------

Install the gem:

```bash
$ gem install channeladvisor
```

Usage
-----

Setup the ChannelAdvisor client:

```ruby
require 'channeladvisor'

ChannelAdvisor.configure do |config|
  config.developer_key = YOUR_DEVELOPER_KEY
  config.password      = YOUR_PASSWORD
  config.account_id    = YOUR_ACCOUNT_ID
end
```

Make a request to the service:

```ruby
date_range = (DateTime.new(2012,05,01)..DateTime.new(2012,06,01))

orders = ChannelAdvisor::Order.list(:created_between => date_range)
# => [<ChannelAdvisor::Order>, <ChannelAdvisor::Order>, ...]

orders.first.id
# => 1234567
```