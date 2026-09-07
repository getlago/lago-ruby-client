# frozen_string_literal: true

module Lago
  module Api
    module Resources
      module PaymentFilters
        ARRAY_FILTERS = %w[
          payment_status payment_statuses payment_provider_type payment_method_type payment_type payable_type
        ].freeze

        def get_all(options = {})
          query_options = options.map do |key, value|
            name = (value.is_a?(Array) && ARRAY_FILTERS.include?(key.to_s)) ? "#{key}[]" : key
            [name, value]
          end

          super(query_options)
        end
      end
    end
  end
end
