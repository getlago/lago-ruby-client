# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Event do
  let(:client) { Lago::Api::Client.new }
  let(:factory_event) { FactoryBot.build(:event) }
  subject(:resource) { described_class.new(client) }

  describe '#create' do
    let(:params) { { 'event' => factory_event.to_h } }

    context 'when event is successfully processed' do
      before do
        stub_request(:post, 'http://api.lago.dev/api/v1/events')
          .to_return(body: '', status: 200)
      end

      it 'returns true' do
        response = resource.create(params)

        expect(response).to be true
      end
    end
  end
end
