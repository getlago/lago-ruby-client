# frozen_string_literal: true

require 'debug'
require 'factory_bot'

require 'lago/version'
require 'lago/api/client'
require 'lago/api/connection'
require 'lago/api/http_error'
require 'lago/api/resources/base'
require 'lago/api/resources/add_on'
require 'lago/api/resources/applied_add_on'
require 'lago/api/resources/applied_coupon'
require 'lago/api/resources/billable_metric'
require 'lago/api/resources/coupon'
require 'lago/api/resources/credit_note'
require 'lago/api/resources/customer'
require 'lago/api/resources/event'
require 'lago/api/resources/fee'
require 'lago/api/resources/group'
require 'lago/api/resources/invoice'
require 'lago/api/resources/organization'
require 'lago/api/resources/plan'
require 'lago/api/resources/subscription'
require 'lago/api/resources/tax'
require 'lago/api/resources/wallet'
require 'lago/api/resources/wallet_transaction'
require 'lago/api/resources/webhook'

require 'webmock/rspec'

require_relative 'support/fixture_helper'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include FixtureHelper

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
