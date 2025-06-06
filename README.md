# Lago Ruby Client

This is a ruby wrapper for Lago API

[![Gem Version](https://badge.fury.io/rb/lago-ruby-client.svg)](https://badge.fury.io/rb/lago-ruby-client)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://spdx.org/licenses/MIT.html)

## Current Releases

| Project              | Release Badge                                                                                                                                         |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Lago**             | [![Lago Release](https://img.shields.io/github/v/release/getlago/lago)](https://github.com/getlago/lago/releases)                                     |
| **Lago Ruby Client** | [![Lago Ruby Client Release](https://img.shields.io/github/v/release/getlago/lago-ruby-client)](https://github.com/getlago/lago-ruby-client/releases) |

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add lago-ruby-client

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install lago-ruby-client

## Usage

Once the gem is installed, you can use it in your Ruby application as follows:

```ruby
require 'lago-ruby-client'

client = Lago::Api::Client.new(api_key: "xyz")
applied_coupons = client.applied_coupons.get_all(
  page: 1,
  per_page: 10,
  "coupon_code[]": ["BLACK_FRIDAY", "CHRISTMAS"],
)

puts "Listing all applied coupons:"
puts applied_coupons
```

For detailed usage, refer to the [lago API reference](https://getlago.com/docs/api-reference/intro).

## Development

### Install the dependencies

```bash
bundle install
```

### Run tests

```bash
bundle exec rspec
```

### Run the linter

```bash
bundle exec rubocop
```

To format the code, run:

```bash
bundle exec rubocop -a # or -A
```

## Documentation

The Lago documentation is available at [doc.getlago.com](https://doc.getlago.com/docs/api/intro).

## Contributing

The contribution documentation is available [here](https://github.com/getlago/lago-ruby-client/blob/main/CONTRIBUTING.md)

## License

Lago Ruby client is distributed under [MIT license](LICENSE).
