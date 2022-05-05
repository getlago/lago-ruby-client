# Lago::Ruby::Client

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

#### Events
``` ruby
params = {
    "event" => {
        "customer_id" => "5eb02857-a71e-4ea2-bcf9-57d8885990ba",
        "code" => "code",
        "timestamp" => 1650893379,
        "properties" => {
            "custom_field" => "custom"
        }
    }
}
client.events.create(params)
```

#### Customers
``` ruby
params = {
    "customer" => {
        "customer_id" => "5eb02857-a71e-4ea2-bcf9-57d8885990ba",
        "name" => "Name"
    }
}
client.customers.create(params)
```

#### Subscriptions
``` ruby
params_create = {
    "subscription" => {
        "customer_id" => "5eb02857-a71e-4ea2-bcf9-57d8885990ba",
        "plan_code" => "code"
    }
}
client.subscription.create(params_create)

params_delete = {
    "customer_id" => "5eb02857-a71e-4ea2-bcf9-57d8885990ba"
}
client.subscription.delete(params_delete)
```

## Development

Run all tests:

    $ bundle exec rspec