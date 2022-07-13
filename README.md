# Lago Ruby Client

This is a ruby wrapper for Lago API

[![Gem Version](https://badge.fury.io/rb/lago-ruby-client.svg)](https://badge.fury.io/rb/lago-ruby-client)

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

``` ruby
transaction_id = "6afadc2a-f28c-40a4-a868-35636f229765"
event = client.events.get(transaction_id)
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
    zipcode: nil,
    billing_configuration: {
        payment_provider: nil,
        provider_customer_id: nil,
        sync: true,
    }
}
client.customers.create(customer)
```

```ruby
customer_usage = client.customer.current_usage(customer_id)
```

### Invoices
[Api reference](https://doc.getlago.com/docs/api/invoices/invoice-object)

``` ruby
params = {
    status: 'succeeded'
}
client.invoices.update(params, '5eb02857-a71e-4ea2-bcf9-57d8885990ba')

client.invoices.get('5eb02857-a71e-4ea2-bcf9-57d8885990ba')

client.invoices.get_all({ per_page: 2, page: 3 })

client.invoices.download("5eb02857-a71e-4ea2-bcf9-57d8885990ba")
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

### Billable Metrics
[Api reference](https://doc.getlago.com/docs/api/billable_metrics/billable-metric-object)

```ruby
billable_metric = {
  name: 'BM1',
  code: 'code_bm',
  description: 'description',
  aggregation_type: 'sum_agg',
  field_name: 'amount_sum',
}

client.billable_metrics.create(billable_metric)

update_params = {
  description: 'description'
}
client.billable_metrics.update(update_params, 'code_bm')

client.billable_metrics.get('code_bm')

client.billable_metrics.destroy('code_bm')

client.billable_metrics.get_all({ per_page: 2, page: 3 })
```

### Add-ons
[Api reference](https://doc.getlago.com/docs/api/add_ons/add-on-object)

```ruby
add_on = {
  name: 'add on name',
  code: 'code',
  description: 'description',
  amount_cents: 100,
  amount_currency: 'EUR',
}

client.add_ons.create(add_on)

update_params = {
  description: 'description'
}
client.add_ons.update(update_params, 'code_bm')

client.add_ons.get('code_bm')

client.add_ons.destroy('code_bm')

client.add_ons.get_all({ per_page: 2, page: 3 })
```

### Coupons
[Api reference](https://doc.getlago.com/docs/api/coupons/coupon-object)

```ruby
coupon = {
  name: 'coupon name',
  code: 'code',
  expiration: 'no_expiration',
  expiration_duration: 10,
  amount_cents: 100,
  amount_currency: 'EUR',
}

client.coupons.create(coupon)

update_params = {
  name: 'new name'
}
client.coupons.update(update_params, 'code_bm')

client.coupons.get('code_bm')

client.coupons.destroy('code_bm')

client.coupons.get_all({ per_page: 2, page: 3 })
```

### Plans
[Api reference](https://doc.getlago.com/docs/api/plans/plan-object)

```ruby
plan = {
  name: 'plan name',
  code: 'code',
  interval: 'monthly',
  description: 'description',
  amount_cents: 100,
  amount_currency: 'EUR',
  pay_in_advance: false,
  charges: [
    {
      billable_metric_id: 'id',
      amount_currency: 'EUR',
      charge_model: 'standard',
      properties: {
        amount: 0.22
      }
    }
  ]
}

client.plans.create(plan)

update_params = {
  name: 'new name'
}
client.plans.update(update_params, 'code_bm')

client.plans.get('code_bm')

client.plans.destroy('code_bm')

client.plans.get_all({ per_page: 2, page: 3 })
```

### Organizations
[Api reference](https://doc.getlago.com/docs/api/organizations/organization-object)

```ruby
update_params = {
  webhook_url: 'https://webhook_url.com',
  vat_rate: 10
}
client.organizations.update(update_params)
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
