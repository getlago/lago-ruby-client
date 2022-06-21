# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Connection do
  subject(:connection) do
    described_class.new(
      'fake-api-key',
      URI('https://testapi.example.org/')
    )
  end

  context 'when an unsuccessful request is made' do
    before do
      stub_request(:post, 'https://testapi.example.org/NOTFOUND')
        .to_return(status: 404, body: "")
    end

    it 'raises an exception with an integer error code' do
      expect { connection.post({}, '/NOTFOUND') }.to raise_error { |exception|
        expect(exception).to be_a(Lago::Api::HttpError)
        expect(exception.error_code).to eq 404
      }
    end
  end
end
