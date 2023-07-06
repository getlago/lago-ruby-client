# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Organization do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:organization_response) { load_fixture(:organization) }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#update' do
    let(:params) { create(:update_organization).to_h }

    context 'when organization is successfully updated' do
      before do
        stub_request(:put, 'https://api.getlago.com/api/v1/organizations')
          .with(body: { organization: params })
          .to_return(body: organization_response, status: 200)
      end

      it 'returns an organization' do
        organization = resource.update(params)

        expect(organization.webhook_url).to eq('https://test-example.example')
        expect(organization.webhook_urls).to eq(['https://test-example.example'])
        expect(organization.tax_identification_number).to eq('EU123456789')
        expect(organization.billing_configuration.invoice_grace_period).to eq(3)
      end
    end

    context 'when organization failed to update' do
      before do
        stub_request(:put, 'https://api.getlago.com/api/v1/organizations')
          .with(body: { organization: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
