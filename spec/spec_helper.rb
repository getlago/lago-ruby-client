# frozen_string_literal: true

require 'factory_bot'
require 'lago/api/client'
require 'lago/api/connection'
require 'lago/api/http_error'
require 'lago/api/resources/base'
require 'lago/api/resources/customer'
require 'lago/api/resources/subscription'
require 'webmock/rspec'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
