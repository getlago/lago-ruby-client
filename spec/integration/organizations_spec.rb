# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#organizations', :integration do
  describe '#update' do
    it 'updates the slug and ignores webhook_urls' do
      original_slug = client.organizations.get(nil).slug
      new_slug = "ruby-#{SecureRandom.hex(6)}"

      begin
        organization = client.organizations.update(slug: new_slug, webhook_urls: ['https://example.com/hook'])

        expect(organization.slug).to eq(new_slug)
        expect(client.organizations.get(nil).slug).to eq(new_slug)
      ensure
        client.organizations.update(slug: original_slug)
      end
    end
  end
end
