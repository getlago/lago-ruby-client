# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::CreditNote do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:credit_note_response) { load_fixture('credit_note') }
  let(:credit_note_id) { JSON.parse(credit_note_response)['credit_note']['lago_id'] }

  let(:not_found_response) do
    {
      'status' => 404,
      'error' => 'Not Found',
      'code' => 'credit_note_not_found',
    }
  end

  let(:validation_error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:params) { create(:create_credit_note).to_h }

    context 'when credit note is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/credit_notes')
          .with(body: { credit_note: params })
          .to_return(body: credit_note_response, status: 200)
      end

      it 'returns a credit_note' do
        response = resource.create(params)

        expect(response.lago_id).to eq(credit_note_id)
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
    let(:params) { create(:update_credit_note).to_h }

    context 'when credit note refund status is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/credit_notes/#{credit_note_id}")
          .with(body: { credit_note: params })
          .to_return(body: credit_note_response, status: 200)
      end

      it 'returns credit note' do
        response = resource.update(params, credit_note_id)

        expect(response.lago_id).to eq(credit_note_id)
      end
    end

    context 'when invoice is NOT successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/credit_notes/#{credit_note_id}")
          .with(body: { credit_note: params })
          .to_return(body: validation_error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, credit_note_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get' do
    context 'when credit note is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/credit_notes/#{credit_note_id}")
          .to_return(body: credit_note_response, status: 200)
      end

      it 'returns a credit note' do
        result = resource.get(credit_note_id)

        expect(result.lago_id).to eq(credit_note_id)
      end
    end

    context 'when credit note is not found' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/credit_notes/#{credit_note_id}")
          .to_return(body: not_found_response.to_json, status: 404)
      end

      it 'raises an error' do
        expect { resource.get(credit_note_id) }
          .to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_all' do
    let(:credit_notes_response) do
      {
        'credit_notes' => [JSON.parse(credit_note_response)['credit_note']],
        'meta' => {
          'current_page' => 1,
          'next_page' => nil,
          'prev_page' => nil,
          'total_pages' => 1,
          'total_count' => 1,
        },
      }.to_json
    end

    before do
      stub_request(:get, 'https://api.getlago.com/api/v1/credit_notes?per_page=2&page=1')
        .to_return(body: credit_notes_response, status: 200)
    end

    it 'returns a list of credit notes' do
      response = resource.get_all({ per_page: 2, page: 1 })

      expect(response['credit_notes'].first['lago_id']).to eq(credit_note_id)
      expect(response['meta']['current_page']).to eq(1)
    end
  end

  describe '#download' do
    before do
      stub_request(:post, "https://api.getlago.com/api/v1/credit_notes/#{credit_note_id}/download")
        .with(body: {})
        .to_return(body: credit_note_response, status: 200)
    end

    it 'returns a credit_note' do
      response = resource.download(credit_note_id)

      expect(response.lago_id).to eq(credit_note_id)
    end
  end

  describe '#void' do
    before do
      stub_request(:put, "https://api.getlago.com/api/v1/credit_notes/#{credit_note_id}/void")
        .with(body: {})
        .to_return(body: credit_note_response, status: 200)
    end

    it 'returns a credit_note' do
      response = resource.void(credit_note_id)

      expect(response.lago_id).to eq(credit_note_id)
    end
  end

  describe '#estimate' do
    let(:estimate_response) { load_fixture(:credit_note_estimated) }
    let(:params) { create(:estimate_credit_note) }

    before do
      stub_request(:post, "https://api.getlago.com/api/v1/credit_notes/estimate")
        .with(body: { credit_note: params.to_h })
        .to_return(body: estimate_response, status: 200)
    end

    it 'returns an estimated credit_note' do
      response = resource.estimate(params)

      expect(response.sub_total_excluding_taxes_amount_cents).to eq(200)
    end
  end
end
