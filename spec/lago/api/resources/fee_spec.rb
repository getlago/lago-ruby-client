# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Fee do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_fee) { FactoryBot.build(:fee) }
  let(:lago_id) { 'this_is_lago_internal_id' }

  let(:response_body) do
    { 'fee' => factory_fee.to_h }
  end

  let(:error_response) do
    {
      'status' => 404,
      'error' => 'Not Found',
      'code' => 'fee_not_found',
    }.to_json
  end

  describe '#get' do
    context 'when fee is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/fees/#{lago_id}")
          .to_return(body: response_body.to_json, status: 200)
      end

      it 'returns a fee' do
        fee = resource.get(lago_id)

        expect(fee.lago_id).to eq(factory_fee.lago_id)
      end
    end

    context 'when fee is not found' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/fees/#{lago_id}")
          .to_return(body: error_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get(lago_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
