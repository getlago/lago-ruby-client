module Lago
  module Api
    module Resources
      class Customer < Base
        def api_resource
          'customers'
        end

        def response_root_name
          'customer'
        end
      end
    end
  end
end
