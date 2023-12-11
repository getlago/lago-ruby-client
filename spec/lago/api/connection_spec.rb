# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Connection do
  subject(:connection) do
    described_class.new(
      'fake-api-key',
      uri
    )
  end

  let(:uri) { URI('https://testapi.example.org') }

  context 'when an unsuccessful request is made' do
    before do
      stub_request(:post, 'https://testapi.example.org/NOTFOUND')
        .to_return(status: 404, body: "")
    end

    it 'raises an exception with an integer error code' do
      expect { connection.post({}, '/NOTFOUND') }.to raise_error { |exception|
        expect(exception).to be_a(Lago::Api::HttpError)
        expect(exception.error_code).to eq 404
      }
    end
  end

  describe '#get' do
    let(:identifier) { 'gid://app/Customer/1234' }

    before do
      stub_request(:get, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F1234')

      allow(URI).to receive(:encode_www_form_component)
        .with(identifier)
        .and_return('gid:%2F%2Fapp%2FCustomer%2F1234')

      connection.get(identifier: identifier)
    end

    it 'encodes the identifier' do
      expect(URI).to have_received(:encode_www_form_component).with(identifier)
    end
  end

  describe '#put' do
    let(:identifier) { 'gid://app/Customer/1234' }

    before do
      stub_request(:put, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F1234')

      allow(URI).to receive(:encode_www_form_component)
        .with(identifier)
        .and_return('gid:%2F%2Fapp%2FCustomer%2F1234')

      connection.put(identifier: identifier, body: nil)
    end

    it 'encodes the identifier' do
      expect(URI).to have_received(:encode_www_form_component).with(identifier)
    end
  end

  describe '#destroy' do
    let(:identifier) { 'gid://app/Customer/1234' }

    before do
      stub_request(:delete, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F1234')

      allow(URI).to receive(:encode_www_form_component)
        .with(identifier)
        .and_return('gid:%2F%2Fapp%2FCustomer%2F1234')

      connection.destroy(identifier: identifier)
    end

    it 'encodes the identifier' do
      expect(URI).to have_received(:encode_www_form_component).with(identifier)
    end
  end
end
