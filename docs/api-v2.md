# API v2 (beta)

The Ruby client supports all 155 operations in the [v2 OpenAPI specification at commit
`caa2b1d`](https://github.com/getlago/lago-openapi/blob/caa2b1d497d903a8637f148d4c0b41b55df54596/openapi-v2.yaml).
API v2 is in beta. Use a Lago instance with the product catalog enabled and an API key with the required resource permissions.
Only operations documented in this specification are exposed.

## Configure the client

```ruby
require 'lago-ruby-client'

client = Lago::Api::V2::Client.new(api_key: ENV.fetch('LAGO_API_KEY'))

# EU cluster. api_url is the server base URL, without /api/v2.
eu_client = Lago::Api::V2::Client.new(
  api_key: ENV.fetch('LAGO_API_KEY'),
  api_url: 'https://api.eu.getlago.com/',
)

# Self-hosted instance.
local_client = Lago::Api::V2::Client.new(
  api_key: ENV.fetch('LAGO_API_KEY'),
  api_url: 'http://localhost:3000/',
)
```

The existing `Lago::Api::Client` continues to use API v1. V1 and v2 clients can be used in the same application.
The v2 client uses its configured API server for event ingestion.

## Create, retrieve, and update resources

Resource methods follow the existing Ruby client's argument order. Pass resource attributes directly;
the client adds the JSON root key required by the endpoint.

```ruby
tax = client.taxes.create(code: 'vat', name: 'VAT', rate: 20)
tax = client.taxes.get('vat')
tax = client.taxes.update({ name: 'VAT 20%' }, 'vat') # PUT
tax = client.taxes.patch({ description: nil }, 'vat') # PATCH
tax = client.taxes.destroy('vat')
```

Single-resource methods return an `OpenStruct` containing the resource attributes.
List methods return an `OpenStruct` containing the collection and any pagination metadata.
Decimal strings and timestamp strings retain their original precision.
The client preserves explicit `nil`, `false`, empty array, and empty object values in request bodies.
Omit attributes that should not be sent. The server validates the supplied attributes.

## Cursor pagination

```ruby
page = client.customers.get_all(limit: 20, include_total_count: true)
page.customers.each { |customer| puts customer.external_id }

if page.meta.next_cursor
  next_page = client.customers.get_all(limit: 20, after: page.meta.next_cursor)
end

if page.meta.prev_cursor
  previous_page = client.customers.get_all(limit: 20, before: page.meta.prev_cursor)
end
```

Pass either `after` or `before`. Treat cursors as opaque strings.
Use `limit` instead of v1's `per_page`; v2 does not use `page`.
`total_count` is returned only when requested on the first page. `total_count_estimated` is present only for estimated counts.
Rate and rate-phase lists return the complete collection without pagination metadata.

## Filters and relationship expansions

```ruby
page = client.customers.get_all(
  limit: 20,
  currencies: ['EUR', 'USD'],
  metadata: { reference: 'account-123' },
  has_customer_type: false,
)

customer = client.customers.get('customer-123', expands: ['taxes'])
```

Array query parameters accept either `currencies:` or `'currencies[]' =>` as their key.
The client sends each array value as a repeated bracketed parameter.
Hash filters use bracket notation, such as `metadata[reference]=account-123`.
Query parameters with a `nil` value are omitted; `false` and empty strings are sent.
Use only the filters and expansions supported by the operation. Relationships are absent unless returned by the server.

## Nested resources

Pass parent identifiers when obtaining a nested resource, then call its methods.
Identifiers and metadata keys are encoded as individual URL path segments.

```ruby
filters = client.product_filters('storage')
page = filters.get_all(limit: 20)
filter = filters.get('region')

rates = client.rate_card_rates('storage-rates').get_all
rates.rates.each { |rate| puts rate.code }

phases = client.plan_rate_phases('standard', 'storage-rates').get_all
phases.rate_phases.each { |phase| puts phase.code }

invoices = client.customers.invoices('customer-123', limit: 20)
methods = client.customers.payment_methods('customer-123', limit: 20)
client.customers.set_default_payment_method('customer-123', 'payment-method-id')
```

## Actions and metadata

```ruby
client.invoices.download_pdf('invoice-id')
client.invoices.void('invoice-id', generate_credit_note: false)
client.invoices.retry_payment('invoice-id', payment_method: { payment_method_id: 'payment-method-id' })
client.payment_receipts.resend_email('receipt-id', to: ['billing@acme.example'])

client.credit_notes.replace_metadata('credit-note-id', reference: 'account-123')
client.credit_notes.update_metadata('credit-note-id', team: 'billing')
client.credit_notes.destroy_metadata_key('credit-note-id', 'reference')
client.credit_notes.destroy_metadata('credit-note-id')

events = client.events.create_batch([
  {
    transaction_id: 'transaction-123',
    code: 'storage',
    external_contract_id: 'contract-123',
    properties: { gigabytes: '12.5' },
  },
])
```

`replace_metadata` replaces all keys. `update_metadata` and `patch_metadata` merge keys.
These methods accept the metadata hash directly.
`create_batch` accepts an array of event attributes and returns an array of event objects.
Actions with an empty response body, including email resend and invoice payment retry, return `nil`.

## Handle errors and rate limits

```ruby
begin
  client.taxes.create(code: 'vat', name: 'VAT')
rescue Lago::Api::V2::HttpError => error
  puts error.http_status # HTTP status, for example 422
  puts error.code        # v2 error code, for example validation_errors
  error.details.each do |detail|
    puts "#{detail['field']}: #{detail['code']}"
    puts detail['meta']
  end
rescue Lago::Api::V2::RateLimitError => error
  puts error.reset
end
```

V2 HTTP errors inherit from `Lago::Api::HttpError`; v2 rate-limit errors inherit from `Lago::Api::RateLimitError`.
Both expose the original response body and URI. `error_code` retains its existing meaning as the HTTP status.
Use `code` for the v2 error code. `details` returns an array of hashes with `code`, `field`, and `meta`.

The client retries HTTP 429 responses up to three times by default. Configure this with `max_retries:`
or disable retries with `retry_on_rate_limit: false`. The existing `on_rate_limit_info:` callback is supported.

## Supported resources

The table lists all supported methods. Standard resource signatures are `get_all(options = {})`,
`get(identifier, options = {})`, `create(params)`, `update(params, identifier)`,
`patch(params, identifier)`, and `destroy(identifier)`.
Other signatures are defined in the corresponding resource class under `lib/lago/api/v2/resources/`.

| Resource accessor | Methods |
| --- | --- |
| `taxes` | `get_all`, `create`, `get`, `update`, `patch`, `destroy` |
| `product_categories` | `get_all`, `create`, `get`, `update`, `patch`, `destroy` |
| `products` | `get_all`, `create`, `get`, `update`, `patch`, `destroy` |
| `product_filters(product_code)` | `get_all`, `create`, `get`, `update`, `patch`, `destroy` |
| `rate_cards` | `get_all`, `create`, `get`, `update`, `patch`, `destroy` |
| `rate_card_rates(rate_card_code)` | `get_all`, `create`, `get`, `update`, `patch`, `destroy` |
| `plans` | `get_all`, `create`, `get`, `update`, `patch` |
| `plan_applied_rate_cards(plan_code)` | `get_all`, `create`, `get`, `update`, `patch`, `destroy` |
| `plan_rate_phases(plan_code, applied_rate_card_code)` | `get_all`, `create`, `update`, `patch`, `destroy` |
| `contract_applied_rate_cards(contract_external_id)` | `get_all`, `create`, `get`, `update`, `patch`, `destroy` |
| `contract_rate_phases(contract_external_id, applied_rate_card_code)` | `get_all`, `create`, `update`, `patch`, `destroy` |
| `contracts` | `get_all`, `create`, `get`, `update`, `patch`, `destroy`, `current_usage` |
| `invoices` | `get_all`, `get`, `update`, `patch`, `destroy`, `void`, `lose_dispute`, `download_pdf`, `resend_email`, `retry_taxes`, `retry_payment`, `finalize`, `refresh`, `payment_url` |
| `fees` | `get_all`, `get`, `update`, `patch`, `destroy` |
| `payments` | `get_all`, `create`, `get` |
| `payment_requests` | `get_all`, `create`, `get` |
| `payment_receipts` | `get_all`, `get`, `resend_email` |
| `credit_notes` | `get_all`, `create`, `get`, `update`, `patch`, `estimate`, `download_pdf`, `download_xml`, `resend_email`, `void`, `replace_metadata`, `update_metadata`, `patch_metadata`, `destroy_metadata`, `destroy_metadata_key` |
| `customers` | `get_all`, `create`, `get`, `update`, `patch`, `destroy`, `checkout_url`, `invoices`, `credit_notes`, `payments`, `payment_requests`, `payment_methods`, `destroy_payment_method`, `set_default_payment_method` |
| `organizations` | `get`, `update` |
| `billing_entities` | `get_all`, `create`, `get`, `update`, `patch` |
| `billable_metrics` | `get_all`, `create`, `get`, `update`, `patch`, `destroy` |
| `events` | `get_all`, `create`, `create_batch` |
| `activity_logs` | `get_all`, `get` |
| `api_logs` | `get_all`, `get` |
| `security_logs` | `get_all`, `get` |
| `webhook_endpoints` | `get_all`, `create`, `get`, `update`, `patch`, `destroy` |

`catalog_plans` is an alias for `plans`. `organizations.get` takes no identifier, and `organizations.update` takes only the attribute hash.
