# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Event do
  subject(:resource) { described_class.new(client) }
  let(:client) { Lago::Api::Client.new }
  let(:factory_event) { FactoryBot.build(:event) }

  describe '#create' do
    let(:params) { factory_event.to_h }
    let(:body) do
      {
        'event' => factory_event.to_h
      }
    end

    context 'when event is successfully processed' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/events')
          .with(body: body)
          .to_return(body: '', status: 200)
      end

      it 'returns true' do
        response = resource.create(params)

        expect(response).to be true
      end
    end
  end
end
