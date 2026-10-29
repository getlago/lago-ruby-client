# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#billing_entities', :integration, :premium do
  # The client cannot delete billing entities, so a single FR billing entity is
  # created on the first run and reused by the following ones.
  let(:billing_entity_code) { 'ruby-sdk-einvoicing' }

  def find_or_create_einvoicing_billing_entity
    client.billing_entities.get(billing_entity_code)
  rescue Lago::Api::HttpError => e
    raise unless e.error_code == 404

    billing_entity = client.billing_entities.create(
      code: billing_entity_code,
      name: 'Ruby SDK einvoicing',
      country: 'FR',
      default_currency: 'EUR',
      einvoicing: true,
    )
    expect(billing_entity.einvoicing).to be true

    billing_entity
  end

  describe '#update' do
    it 'updates einvoicing' do
      original_einvoicing = find_or_create_einvoicing_billing_entity.einvoicing

      begin
        updated = client.billing_entities.update({ einvoicing: true }, billing_entity_code)
        fetched = client.billing_entities.get(billing_entity_code)

        expect(updated.einvoicing).to be true
        expect(fetched.einvoicing).to be true

        disabled = client.billing_entities.update({ einvoicing: false }, billing_entity_code)

        expect(disabled.einvoicing).to be false
      ensure
        client.billing_entities.update({ einvoicing: original_einvoicing }, billing_entity_code)
      end
    end
  end
end
