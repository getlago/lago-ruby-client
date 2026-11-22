# frozen_string_literal: true

require 'lago/api/http_error'
require 'lago/api/v2/error_details'

module Lago
  module Api
    module V2
      class HttpError < Lago::Api::HttpError
        include ErrorDetails
      end
    end
  end
end
