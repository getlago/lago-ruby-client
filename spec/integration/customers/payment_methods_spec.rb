# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#customer_payment_methods', :integration do
  let(:customer) { create_customer(presets: [:us]) }

  describe '#destroy' do
    it 'raises an error for non-existent payment method' do
      expect {
        client.customer_payment_methods(customer.external_id).destroy('non-existent-id')
      }.to raise_error(Lago::Api::HttpError)
    end
  end

  describe '#set_as_default' do
    it 'raises an error for non-existent payment method' do
      expect {
        client.customer_payment_methods(customer.external_id).set_as_default('non-existent-id')
      }.to raise_error(Lago::Api::HttpError)
    end
  end
end
