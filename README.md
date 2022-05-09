# Lago Ruby Client

This is a ruby wrapper for Lago API

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add lago-ruby-client

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install lago-ruby-client

## Usage

``` ruby
require 'lago-ruby-client'

client = Lago::Api::Client.new({api_key: 'key'})
```

### Events
[Api reference](https://doc.getlago.com/docs/api-reference/events)

``` ruby
event = {
    transaction_id: "__UNIQUE_ID__",
    customer_id:  "5eb02857-a71e-4ea2-bcf9-57d8885990ba",
    code:  "code",
    timestamp:  1650893379,
    properties: {
        custom_field: "custom"
    }
}
client.events.create(event)
```

### Customers
[Api reference](https://doc.getlago.com/docs/api-reference/customers)

``` ruby
customer = {
    customer_id: "5eb02857-a71e-4ea2-bcf9-57d8885990ba",
    address_line1: nil,
    address_line2: nil,
    city: nil,
    country: nil,
    email: "test@example.com",
    legal_name: nil,
    legal_number: nil,
    logo_url: nil,
    name: "test name",
    phone: nil,
    state: nil,
    url: nil,
    vat_rate: nil,
    zipcode: nil
}
client.customers.create(customer)
```

### Subscriptions
[Api reference](https://doc.getlago.com/docs/api-reference/subscriptions)

``` ruby
subscription = {
    customer_id: "5eb02857-a71e-4ea2-bcf9-57d8885990ba",
    plan_code: "code"
}
client.subscriptions.create(subscription)

params_delete = {
    customer_id: "5eb02857-a71e-4ea2-bcf9-57d8885990ba"
}
client.subscriptions.delete(params_delete)
```

## Development

Run all tests:

    $ bundle exec rspec