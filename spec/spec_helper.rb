# frozen_string_literal: true

require 'debug'
require 'pry-byebug'
require 'factory_bot'
require 'lago-ruby-client'
require 'webmock/rspec'
require 'ostruct'
require 'httplog'
require_relative 'support/fixture_helper'
require_relative 'support/integration_helper'

HttpLog.configure do |config|
  config.enabled = true

  FileUtils.mkdir_p('log')
  config.logger = Logger.new('log/httplog.log')
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include FixtureHelper

  IntegrationHelper.configure(config)

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

  config.filter_run_when_matching :focus
end
