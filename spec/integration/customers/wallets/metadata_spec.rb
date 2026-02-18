# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#customers.wallets.metadata', :integration do
  let(:customer) { create_customer(presets: [:us]) }
  let(:wallet) do
    client.customers.wallets.create(
      customer.external_id,
      {
        name: "Test Wallet #{customer_unique_id(customer)}",
        priority: 30,
        rate_amount: 2,
        metadata: {
          one: 'one',
          two: 'two',
        },
      },
    )
  end

  describe '#replace' do
    it 'replaces metadata' do
      metadata = client.customers.wallets.metadata.replace(
        customer.external_id,
        wallet.code,
        { three: 'three' },
      )

      expect(metadata).to eq('three' => 'three')
    end
  end

  describe '#merge' do
    it 'merges metadata' do
      metadata = client.customers.wallets.metadata.merge(
        customer.external_id,
        wallet.code,
        { three: 'three' },
      )

      expect(metadata).to eq('one' => 'one', 'two' => 'two', 'three' => 'three')
    end
  end

  describe '#delete_key' do
    it 'deletes a key-value pair by key' do
      metadata = client.customers.wallets.metadata.delete_key(
        customer.external_id,
        wallet.code,
        'one',
      )

      expect(metadata).to eq('two' => 'two')
    end
  end

  describe '#delete_all' do
    it 'deletes all metadata' do
      metadata = client.customers.wallets.metadata.delete_all(
        customer.external_id,
        wallet.code,
      )

      expect(metadata).to be_nil
    end
  end
end
