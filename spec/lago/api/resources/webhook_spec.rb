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

  describe 'valid_standard_webhooks_signature?' do
    let(:secret) { 'whsec_AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=' }
    let(:webhook_id) { '8b2f6a1e-3c4d-4e5f-9a6b-7c8d9e0f1a2b' }
    let(:timestamp) { '1762300800' }
    let(:raw_body) { '{"webhook_type":"invoice.created","amount_cents":100}' }
    let(:signature) { 'v1,Kb+qawXvtjgaYfg4mZ5Nwx56fhXVFDUa+V+BmUirSEY=' }
    let(:now) { Time.at(1_762_300_800) }
    let(:headers) do
      {
        'webhook-id' => webhook_id,
        'webhook-timestamp' => timestamp,
        'webhook-signature' => signature,
      }
    end

    before { allow(Time).to receive(:now).and_return(now) }

    def sign(body)
      key = Base64.decode64(secret.delete_prefix('whsec_'))
      digest = OpenSSL::HMAC.digest('sha256', key, "#{webhook_id}.#{timestamp}.#{body}")

      "v1,#{Base64.strict_encode64(digest)}"
    end

    it 'accepts the reference test vector' do
      expect(resource).to be_valid_standard_webhooks_signature(raw_body, headers, secret)
    end

    it 'makes no network call' do
      resource.valid_standard_webhooks_signature?(raw_body, headers, secret)

      expect(a_request(:any, /api\.getlago\.com/)).not_to have_been_made
    end

    it 'accepts mixed-case header names' do
      mixed_headers = {
        'Webhook-Id' => webhook_id,
        'WEBHOOK-TIMESTAMP' => timestamp,
        'Webhook-Signature' => signature,
      }

      expect(resource).to be_valid_standard_webhooks_signature(raw_body, mixed_headers, secret)
    end

    it 'accepts symbol header names' do
      symbol_headers = {
        'webhook-id': webhook_id,
        'Webhook-Timestamp': timestamp,
        'webhook-signature': signature,
      }

      expect(resource).to be_valid_standard_webhooks_signature(raw_body, symbol_headers, secret)
    end

    context 'with several signatures in the header and one matching' do
      let(:signature) { 'v1,AAAA v1,Kb+qawXvtjgaYfg4mZ5Nwx56fhXVFDUa+V+BmUirSEY=' }

      it 'accepts the delivery' do
        expect(resource).to be_valid_standard_webhooks_signature(raw_body, headers, secret)
      end
    end

    context 'with a malformed entry before the matching signature' do
      let(:signature) { 'v1 v1,Kb+qawXvtjgaYfg4mZ5Nwx56fhXVFDUa+V+BmUirSEY=' }

      it 'accepts the delivery' do
        expect(resource.valid_standard_webhooks_signature?(raw_body, headers, secret)).to be(true)
      end
    end

    context 'with a non-ASCII webhook id and a binary body' do
      let(:raw_body) { '{"a":"é"}'.b }
      let(:webhook_id) { 'idé' }

      it 'rejects the delivery without raising' do
        expect(resource.valid_standard_webhooks_signature?(raw_body, headers, secret)).to be(false)
      end
    end

    context 'when the timestamp is 299 seconds old' do
      let(:now) { Time.at(1_762_300_800 + 299) }

      it 'accepts the delivery' do
        expect(resource).to be_valid_standard_webhooks_signature(raw_body, headers, secret)
      end
    end

    context 'when the timestamp is 299 seconds in the future' do
      let(:now) { Time.at(1_762_300_800 - 299) }

      it 'accepts the delivery' do
        expect(resource).to be_valid_standard_webhooks_signature(raw_body, headers, secret)
      end
    end

    context 'with a signed null body' do
      let(:raw_body) { 'null' }
      let(:signature) { sign('null') }

      it 'returns true' do
        expect(resource.valid_standard_webhooks_signature?(raw_body, headers, secret)).to be(true)
      end
    end

    context 'when the timestamp is more than 5 minutes old' do
      let(:now) { Time.at(1_762_300_800 + 301) }

      it 'rejects the delivery' do
        expect(resource.valid_standard_webhooks_signature?(raw_body, headers, secret)).to be(false)
      end
    end

    context 'when the timestamp is more than 5 minutes in the future' do
      let(:now) { Time.at(1_762_300_800 - 301) }

      it 'rejects the delivery' do
        expect(resource.valid_standard_webhooks_signature?(raw_body, headers, secret)).to be(false)
      end
    end

    it 'rejects a tampered body' do
      tampered_body = '{"webhook_type":"invoice.created","amount_cents":101}'

      expect(resource.valid_standard_webhooks_signature?(tampered_body, headers, secret)).to be(false)
    end

    it 'rejects a wrong secret' do
      wrong_secret = 'whsec_HxwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQQDAgEAAAA='

      expect(resource.valid_standard_webhooks_signature?(raw_body, headers, wrong_secret)).to be(false)
    end

    it 'rejects a changed webhook id' do
      changed_headers = headers.merge('webhook-id' => '00000000-0000-0000-0000-000000000000')

      expect(resource.valid_standard_webhooks_signature?(raw_body, changed_headers, secret)).to be(false)
    end

    %w[webhook-id webhook-timestamp webhook-signature].each do |header_name|
      it "rejects a delivery without the #{header_name} header" do
        expect(resource.valid_standard_webhooks_signature?(raw_body, headers.except(header_name), secret)).to be(false)
      end
    end

    it 'rejects nil headers' do
      expect(resource.valid_standard_webhooks_signature?(raw_body, nil, secret)).to be(false)
    end

    context 'with a signature without a comma' do
      let(:signature) { 'v1' }

      it 'rejects the delivery' do
        expect(resource.valid_standard_webhooks_signature?(raw_body, headers, secret)).to be(false)
      end
    end

    context 'with a valid signature under another version' do
      let(:signature) { 'v2,Kb+qawXvtjgaYfg4mZ5Nwx56fhXVFDUa+V+BmUirSEY=' }

      it 'rejects the delivery' do
        expect(resource.valid_standard_webhooks_signature?(raw_body, headers, secret)).to be(false)
      end
    end

    context 'with a signature of the same length but other byte size' do
      let(:signature) { "v1,#{'é' * 44}" }

      it 'rejects the delivery' do
        expect(resource.valid_standard_webhooks_signature?(raw_body, headers, secret)).to be(false)
      end
    end

    it 'rejects a nil secret' do
      expect(resource.valid_standard_webhooks_signature?(raw_body, headers, nil)).to be(false)
    end

    it 'rejects an empty secret' do
      expect(resource.valid_standard_webhooks_signature?(raw_body, headers, '')).to be(false)
    end

    context 'with a non-integer timestamp' do
      let(:timestamp) { 'abc' }

      it 'rejects the delivery' do
        expect(resource.valid_standard_webhooks_signature?(raw_body, headers, secret)).to be(false)
      end
    end

    context 'with a correctly signed non-JSON body' do
      let(:raw_body) { 'not json' }
      let(:signature) { sign('not json') }

      it 'rejects the delivery' do
        expect(resource.valid_standard_webhooks_signature?(raw_body, headers, secret)).to be(false)
      end
    end

    context 'with a nil body matching a signature of an empty body' do
      let(:signature) { sign('') }

      it 'rejects the delivery' do
        expect(resource.valid_standard_webhooks_signature?(nil, headers, secret)).to be(false)
      end
    end
  end
end
