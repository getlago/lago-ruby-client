# frozen_string_literal: true

require 'lago/api/rate_limit_error'
require 'lago/api/v2/error_details'

module Lago
  module Api
    module V2
      class RateLimitError < Lago::Api::RateLimitError
        include ErrorDetails
      end
    end
  end
end
