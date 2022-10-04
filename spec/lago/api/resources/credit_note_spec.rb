# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::CreditNote do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:credit_note) { build(:credit_note) }
  let(:lago_id) { 'lago_internal_id' }

  let(:not_found_response) do
    {
      'status' => 404,
      'error' => 'Not Found',
      'code' => 'credit_note_not_found'
    }
  end

  let(:validation_error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record'
    }.to_json
  end

  describe '#create' do
    let(:params) do
      {
        invoice_id: 'some-lago-invoice-id',
        reason: 'duplicated_charge',
        items: [
          {
            fee_id: 'some-lago-fee-id-1',
            credit_amount_cents: 10,
            refund_amount_cents: 5
          },
          {
            fee_id: 'some-lago-fee-id-2',
            credit_amount_cents: 5,
            refund_amount_cents: 10
          }
        ]
      }
    end

    let(:response_body) do
      {
        'credit_note' => credit_note.to_h
      }
    end

    context 'when credit note is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/credit_notes')
          .with(body: { credit_note: params }.to_json)
          .to_return(body: response_body.to_json, status: 200)
      end

      it 'returns a credit_note' do
        response = resource.create(params)

        expect(response.lago_id).to eq(credit_note.lago_id)
      end
    end

    context 'when credit note failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/credit_notes')
          .with(body: { credit_note: params }.to_json)
          .to_return(body: validation_error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update' do
    let(:params) do
      {
        refund_status: 'pending'
      }
    end

    let(:request_body) do
      {
        'credit_note' => {
          'refund_status' => credit_note.refund_status
        }
      }
    end

    context 'when credit note refund status is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/credit_notes/#{credit_note.lago_id}")
          .with(body: request_body.to_json)
          .to_return(body: { credit_note: credit_note.to_h }.to_json, status: 200)
      end

      it 'returns credit note' do
        response = resource.update(params, credit_note.lago_id)

        expect(response.lago_id).to eq(credit_note.lago_id)
      end
    end

    context 'when invoice is NOT successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/credit_notes/#{credit_note.lago_id}")
          .with(body: request_body.to_json)
          .to_return(body: validation_error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, credit_note.lago_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get' do
    let(:response_body) do
      {
        'credit_note' => credit_note.to_h
      }
    end

    context 'when credit note is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/credit_notes/#{lago_id}")
          .to_return(body: response_body.to_json, status: 200)
      end

      it 'returns a credit note' do
        result = resource.get(lago_id)

        expect(result.lago_id).to eq(credit_note.lago_id)
      end
    end

    context 'when credit note is not found' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/credit_notes/#{lago_id}")
          .to_return(body: not_found_response.to_json, status: 404)
      end

      it 'raises an error' do
        expect { resource.get(lago_id) }
          .to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_all' do
    let(:response_body) do
      {
        'credit_notes' => [credit_note.to_h],
        'meta' => {
          'current_page' => 1,
          'next_page' => nil,
          'prev_page' => nil,
          'total_pages' => 1,
          'total_count' => 1
        }
      }
    end

    before do
      stub_request(:get, 'https://api.getlago.com/api/v1/credit_notes?per_page=2&page=1')
        .to_return(body: response_body.to_json, status: 200)
    end

    it 'returns a list of credit notes' do
      response = resource.get_all({ per_page: 2, page: 1 })

      expect(response['credit_notes'].first['lago_id']).to eq(credit_note.lago_id)
      expect(response['meta']['current_page']).to eq(1)
    end
  end

  describe '#download' do
    let(:response_body) do
      {
        'credit_note' => credit_note.to_h
      }
    end

    before do
      stub_request(:post, 'https://api.getlago.com/api/v1/credit_notes/123456/download')
        .with(body: {})
        .to_return(body: response_body.to_json, status: 200)
    end

    it 'returns a credit_note' do
      response = resource.download('123456')

      expect(response.lago_id).to eq(credit_note.id)
    end
  end

  describe '#void' do
    let(:response_body) do
      {
        'credit_note' => credit_note.to_h
      }
    end

    before do
      stub_request(:put, 'https://api.getlago.com/api/v1/credit_notes/123456/void')
        .with(body: {})
        .to_return(body: response_body.to_json, status: 200)
    end

    it 'returns a credit_note' do
      response = resource.void('123456')

      expect(response.lago_id).to eq(credit_note.id)
    end
  end
end
