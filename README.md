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
[Api reference](https://doc.getlago.com/docs/api/events)

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
[Api reference](https://doc.getlago.com/docs/api/customers/customer-object)

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
[Api reference](https://doc.getlago.com/docs/api/subscriptions/subscription-object)

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

### Applied coupons
[Api reference](https://doc.getlago.com/docs/api/applied_coupons/applied-coupon-object)

```ruby
applied_coupon = {
  customer_id: "5eb02857-a71e-4ea2-bcf9-57d3a41bc6ba",
  coupon_code: "code",
  amount_cents: 123,
  amount_currency: "EUR"
}

client.applied_coupons.create(applied_coupon)
```

### Applied add-ons
[Api reference](https://doc.getlago.com/docs/api/applied_add_ons/applied-add-on-object)

```ruby
applied_add_on = {
  customer_id: "5eb02857-a71e-4ea2-bcf9-57d3a41bc6ba",
  add_on_code: "code",
  amount_cents: 123,
  amount_currency: "EUR"
}

client.applied_add_ons.create(applied_add_on)
```

## Development

### Install the dependencies

```bash
bundle install
```

### Run tests

```bash
bundle exec rspec
```

## Documentation

The Lago documentation is available at [doc.getlago.com](https://doc.getlago.com/docs/api/intro).

## Contributing

The contribution documentation is available [here](https://github.com/getlago/lago-ruby-client/blob/main/CONTRIBUTING.md)

## License

Lago Ruby client is distributed under [AGPL-3.0](LICENSE).
