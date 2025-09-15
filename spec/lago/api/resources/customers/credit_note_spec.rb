# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Customers::CreditNote do
  subject(:resource) { described_class.new(client, resource_id) }

  let(:client) { Lago::Api::Client.new }

  let(:resource_id) { 'customer_external_id' }
  let(:credit_note_response) { load_fixture('credit_note') }
  let(:credit_note_id) { JSON.parse(credit_note_response)['credit_note']['lago_id'] }
  let(:tax) { create(:create_tax) }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#get_all' do
    let(:credit_notes_response) do
      {
        'credit_notes' => [JSON.parse(credit_note_response)['credit_note']],
        'meta': {
          'current_page' => 1,
          'next_page' => 2,
          'prev_page' => nil,
          'total_pages' => 7,
          'total_count' => 63,
        },
      }.to_json
    end

    context 'when there is no options' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/credit_notes")
          .to_return(body: credit_notes_response, status: 200)
      end

      it 'returns credit_notes on the first page' do
        response = resource.get_all

        expect(response['credit_notes'].first['lago_id']).to eq(credit_note_id)
        expect(response['credit_notes'].first['credit_status']).to eq('available')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/credit_notes?per_page=2&page=1")
          .to_return(body: credit_notes_response, status: 200)
      end

      it 'returns credit_notes on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['credit_notes'].first['lago_id']).to eq(credit_note_id)
        expect(response['credit_notes'].first['credit_status']).to eq('available')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/credit_notes")
          .to_return(body: error_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
