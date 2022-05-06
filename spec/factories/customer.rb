FactoryBot.define do
  factory :customer, class: OpenStruct do
    customer_id { '5eb02857-a71e-4ea2-bcf9-57d8885436ba' }
    name { 'Gavin Belson' }
    vat_rate { nil }
    country { 'US' }
    address_line1 { '5230 Penfield Ave' }
    address_line2 {'fzufuzfuz' }
    state { 'CA' }
    zipcode { '91364' }
    email { 'dinesh@piedpiper.test' }
    city { 'Woodland Hills' }
    url { '<http://hooli.com>' }
    phone { '1-171-883-3711 x245' }
    logo_url { 'http://hooli.com/logo.png' }
    legal_name { 'Coleman-Blair' }
    legal_number { '49-008-2965' }
  end
end
