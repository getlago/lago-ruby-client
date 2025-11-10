# frozen_string_literal: true

require 'lago-ruby-client'

module IntegrationHelper
  module ClassMethods
    def before_all_integration_tests(&block)
      return unless IntegrationHelper.integration_tests_enabled?

      before(:all, &block)
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.integration_tests_enabled?
    ENV['INTEGRATION_TESTS_ENABLED'] == 'true'
  end

  def self.premium_license?
    ENV['INTEGRATION_TESTS_PREMIUM_LICENSE'] == 'true'
  end

  def self.configure(config)
    config.include IntegrationHelper, :integration

    unless integration_tests_enabled?
      config.filter_run_excluding :integration
      return
    end

    config.filter_run_excluding :premium unless premium_license?

    api_url = ENV['TEST_LAGO_API_URL']
    api_key = ENV['TEST_LAGO_API_KEY']
    raise 'TEST_LAGO_API_URL must be set to run integration tests' if api_url.blank?
    raise 'TEST_LAGO_API_KEY must be set to run integration tests' if api_key.blank?

    config.before(:all, :integration) do
      uri = URI.parse(ENV['TEST_LAGO_API_URL'])

      WebMock.disable_net_connect!(allow: uri.host)
    end
  end

  def client
    @client ||= Lago::Api::Client.new(api_key: ENV.fetch('TEST_LAGO_API_KEY'), api_url: ENV.fetch('TEST_LAGO_API_URL'))
  end

  def deep_to_h(object)
    case object
    when Hash, OpenStruct
      object.to_h { |key, value| [key, deep_to_h(value)] }
    when Array
      object.map { |v| deep_to_h(v) }
    else
      object
    end
  end

  CUSTOMER_PRESETS = {
    french: {
      currency: 'EUR',
      country: 'FR',
      address_line1: '123 Main St',
      address_line2: 'Apt 1',
      city: 'Paris',
      zipcode: '75001',
      state: 'Paris',
      phone: '0601020304',
      legal_number: 'FR1234567890',
      timezone: 'Europe/Paris',
    },
    us: {
      currency: 'USD',
      country: 'US',
      address_line1: '123 Main St',
      address_line2: 'Apt 1',
      city: 'San Francisco',
      zipcode: '94101',
      state: 'CA',
      phone: '0601020304',
      legal_number: 'US1234567890',
      timezone: 'America/New_York',
    },
  }.freeze

  def create_customer(params: {}, presets: [])
    external_id = unique_id
    create_params = {
      external_id: "ExternalID #{external_id}",
      firstname: "Firstname #{external_id}",
      lastname: "Lastname #{external_id}",
      name: "Name | #{external_id}",
      email: "yohan+#{external_id}@getlago.com",
      legal_name: "LegalName #{external_id}",
    }
    presets.each do |preset|
      raise "Preset #{preset} not found" unless CUSTOMER_PRESETS.key?(preset.to_sym)

      create_params.merge!(CUSTOMER_PRESETS[preset])
    end
    create_params.merge!(params)

    client.customers.create(create_params)
  end

  BILLABLE_METRIC_PRESETS = {
    sum_agg: {
      aggregation_type: 'sum_agg',
      field_name: 'value',
    },
    count_agg: {
      aggregation_type: 'count_agg',
    },
    unique_count_agg: {
      aggregation_type: 'unique_count_agg',
      field_name: 'value',
    },
  }.freeze
  def create_billable_metric(params: {}, presets: [])
    create_params = {}
    presets.each do |preset|
      raise "Preset #{preset} not found" unless BILLABLE_METRIC_PRESETS.key?(preset.to_sym)

      create_params.merge!(BILLABLE_METRIC_PRESETS[preset])
    end
    create_params.merge!(params)

    agg_type = create_params[:aggregation_type]
    create_params[:name] = "#{agg_type} | #{unique_id}"
    create_params[:code] = "#{agg_type}-#{unique_id}"

    client.billable_metrics.create(create_params)
  end

  def create_plan(params: {}, presets: [])
    create_params = {}
    presets.each do |preset|
      raise "Preset #{preset} not found" unless PLAN_PRESETS.key?(preset.to_sym)

      create_params.merge!(PLAN_PRESETS[preset])
    end
    create_params.merge!(params)

    create_params[:name] = "Plan | #{unique_id}"
    create_params[:code] = "plan-#{unique_id}"
    create_params[:interval] ||= 'monthly'
    create_params[:amount_cents] ||= 1000
    create_params[:amount_currency] ||= 'EUR'
    create_params[:trial_period] ||= 0
    create_params[:pay_in_advance] ||= false
    create_params[:bill_charges_monthly] ||= false
    create_params[:charges] ||= []
    create_params[:minimum_commitment] ||= {}
    create_params[:taxes] ||= []

    client.plans.create(create_params)
  end

  def create_subscription(plan_code:, external_customer_id:, params: {})
    create_params = {
      plan_code:,
      external_customer_id:,
      external_id: "sub-#{unique_id}",
    }
    create_params.merge!(params)

    client.subscriptions.create(create_params)
  end

  def unique_id
    "ruby-#{Time.now.strftime('%Y-%m-%dT%H-%M-%S-%L')}"
  end

  def customer_unique_id(customer)
    customer.external_id.split('-').last
  end

<<<<<<< HEAD
||||||| parent of 2c4fc34 (test: Add wallet, credit note and invoice integration tests)
=======
  def unique_id_regex
    /ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}/
  end

>>>>>>> 2c4fc34 (test: Add wallet, credit note and invoice integration tests)
  def wait_until(timeout = 10)
    Timeout.timeout(timeout) do
      sleep 0.01 until yield
    end
  end
end
