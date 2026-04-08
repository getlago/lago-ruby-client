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

  before do
    stub_const('Lago::Api::Connection::RETRY_WAIT_TIME_IN_SECONDS', 0)
  end

  context 'when an unsuccessful request is made' do
    before do
      stub_request(:post, 'https://testapi.example.org/NOTFOUND')
        .to_return(status: 404, body: '')
    end

    it 'raises an exception with an integer error code' do
      expect { connection.post({}, '/NOTFOUND') }.to(
        raise_error do |exception|
          expect(exception).to be_a(Lago::Api::HttpError)
          expect(exception.error_code).to eq 404
        end
      )
    end
  end

  describe '#get_all' do
    let(:options) { { page: 1, per_page: 10 } }

    it do
      stub = stub_request(:get, 'https://testapi.example.org/?page=1&per_page=10')

      connection.get_all(options, uri)

      expect(stub).to have_been_requested
    end

    context 'when api returns 429' do
      before do
        stub_request(:get, 'https://testapi.example.org/?page=1&per_page=10')
          .to_return(status: 429, body: '').then.to_return(status: 200, body: '{"success":true}')
      end

      it 'auto retries the request' do
        response = connection.get_all(options, uri)
        expect(response).to eq({ 'success' => true })
      end
    end

    context 'when api returns 429 (2 times)' do
      before do
        stub_request(:get, 'https://testapi.example.org/?page=1&per_page=10')
          .to_return(status: 429, body: '').times(2).then.to_return(status: 200, body: '{"success":true}')
      end

      it 'auto retries the request' do
        response = connection.get_all(options, uri)
        expect(response).to eq({ 'success' => true })
      end
    end
  end

  describe '#get' do
    let(:identifier) { 'gid://app/Customer/12 34' }

    it 'encodes the identifier' do
      stub = stub_request(:get, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')
      connection.get(identifier: identifier)

      expect(stub).to have_been_requested
    end

    context 'when api returns 429' do
      before do
        stub_request(:get, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')
          .to_return(status: 429, body: '').then.to_return(status: 200, body: '{"success":true}')
      end

      it 'auto retries the request' do
        response = connection.get(identifier: identifier)
        expect(response).to eq({ 'success' => true })
      end
    end

    context 'when api returns 429 (2 times)' do
      before do
        stub_request(:get, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')
          .to_return(status: 429, body: '').times(2).then.to_return(status: 200, body: '{"success":true}')
      end

      it 'auto retries the request' do
        response = connection.get(identifier: identifier)
        expect(response).to eq({ 'success' => true })
      end
    end
  end

  describe '#put' do
    let(:identifier) { 'gid://app/Customer/12 34' }

    it 'encodes the identifier' do
      stub = stub_request(:put, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')
      connection.put(identifier: identifier, body: nil)

      expect(stub).to have_been_requested
    end

    context 'when api returns 429' do
      before do
        stub_request(:put, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')
          .to_return(status: 429, body: nil).then.to_return(status: 200, body: '{"success":true}')
      end

      it 'auto retries the request' do
        response = connection.put(identifier: identifier, body: nil)
        expect(response).to eq({ 'success' => true })
      end
    end

    context 'when api returns 429 (2 times)' do
      before do
        stub_request(:put, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')
          .to_return(status: 429, body: nil).times(2).then.to_return(status: 200, body: '{"success":true}')
      end

      it 'auto retries the request' do
        response = connection.put(identifier: identifier, body: nil)
        expect(response).to eq({ 'success' => true })
      end
    end
  end

  describe '#patch' do
    let(:identifier) { 'gid://app/Customer/12 34' }

    it 'encodes the identifier' do
      stub = stub_request(:patch, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')
      connection.patch(identifier: identifier, body: nil)

      expect(stub).to have_been_requested
    end

    context 'when api returns 429' do
      before do
        stub_request(:patch, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')
          .to_return(status: 429, body: nil).then.to_return(status: 200, body: '{"success":true}')
      end

      it 'auto retries the request' do
        response = connection.patch(identifier: identifier, body: nil)
        expect(response).to eq({ 'success' => true })
      end
    end

    context 'when api returns 429 (2 times)' do
      before do
        stub_request(:patch, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')
          .to_return(status: 429, body: nil).times(2).then.to_return(status: 200, body: '{"success":true}')
      end

      it 'auto retries the request' do
        response = connection.patch(identifier: identifier, body: nil)
        expect(response).to eq({ 'success' => true })
      end
    end
  end

  describe '#destroy' do
    let(:identifier) { 'gid://app/Customer/12 34' }

    it 'encodes the identifier' do
      stub = stub_request(:delete, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')
      connection.destroy(identifier: identifier)

      expect(stub).to have_been_requested
    end
  end
end
