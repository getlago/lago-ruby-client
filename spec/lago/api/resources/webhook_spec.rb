# frozen_string_literal: true

require 'jwt'
require 'spec_helper'

RSpec.describe Lago::Api::Resources::Webhook do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:private_key_string) do
    File.read('spec/fixtures/certificates/jwtRS256.key')
  end

  let(:private_key) { OpenSSL::PKey::RSA.new(private_key_string) }
  let(:public_key) { private_key.public_key }
  let(:response) do
    {
      'webhook' => {
        'public_key' => Base64.encode64(public_key.to_s),
      },
    }.to_json
  end

  before do
    stub_request(:get, 'https://api.getlago.com/api/v1/webhooks/json_public_key')
      .to_return(body: response, status: 200)
  end

  describe 'public_key' do
    it 'downloads the signature public key' do
      result = resource.public_key

      expect(result.to_s).to eq(public_key.to_s)
    end
  end

  describe 'valid_signature?' do
    let(:signature) do
      JWT.encode(
        {
          data: payload.to_json,
          iss: issuer,
        },
        private_key,
        'RS256',
      )
    end

    let(:payload) do
      {
        'invoice' => {
          'id' => '123456789',
          'amount' => 123,
        },
      }
    end

    let(:issuer) { Lago::Api::BASE_URL }

    it 'validates the payload against the signature' do
      expect(resource).to be_valid_signature(signature, payload)
    end

    context 'with invalid issuer' do
      let(:issuer) { 'https://foo.bar' }

      it 'fails the validation' do
        expect(resource).not_to be_valid_signature(signature, payload)
      end
    end

    context 'with invalid payload' do
      it 'fails the validation' do
        expect(resource).not_to be_valid_signature(signature, { 'foo' => 'bar' })
      end
    end

    context 'with invalid cached signature' do
      let(:public_key_file) do
        File.read('spec/fixtures/certificates/invalid.key.pub')
      end

      let(:invalid_public_key) do
        OpenSSL::PKey::RSA.new(public_key_file)
      end

      it 'fails the validation' do
        expect(resource).not_to be_valid_signature(signature, payload, invalid_public_key)
      end
    end
  end
end
