# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Client do
  let(:api_url) { 'http://test.api.url/' }

  subject(:client) do
    described_class.new(
      api_key: '123456',
      api_url: api_url
    )
  end

  describe '#base_api_url' do
    context 'when api_url is given' do
      it { expect(client.base_api_url).to eq(URI("#{api_url}api/v1/")) }
    end

    context 'when api_url is NOT given' do
      let(:api_url) { nil }

      it { expect(client.base_api_url).to eq(URI('http://api.lago.dev/api/v1/')) }
    end
  end
end
