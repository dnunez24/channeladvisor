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
date_range = DateTime.new(2012,05,01)..DateTime.new(2012,06,01)

orders = ChannelAdvisor::Order.list(:created_between => date_range)
# => [#<ChannelAdvisor::Order>, #<ChannelAdvisor::Order>, ...]

orders.first.id
# => 1234567
```

Organization
------------

The API wrapper is organized into two distinct segments. The `ChannelAdvisor::Services` module directly corresponds to the services and methods in the ChannelAdvisor API. Utilizing this interface ensures consistency with the actual ChannelAdvisor interface and will also allow you to handle errors and response data your own way, i.e. making a minimal amount of assumptions about how to handle the data returned from the web service request. A second, simpler interface is designed for ease-of-use and makes some assumptions about how best to handle the data and errors in the API response. For example, the simple interface would
work like this:

```ruby
ChannelAdvisor::Order.list(:state => "Active")
# => [#<ChannelAdvisor::Order>, #<ChannelAdvisor::Order>, ...]
```

While the `Services` interface would work like this:

```ruby
ChannelAdvisor::Services::OrderService.get_order_list(:state => "Active")
# => #<Savon::SOAP::Response>
# ... do some neat stuff with the SOAP response
```