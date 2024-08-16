# frozen_string_literal: true

require 'debug'
require 'factory_bot'

require 'lago-ruby-client'

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
