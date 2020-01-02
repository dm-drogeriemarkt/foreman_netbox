# frozen_string_literal: true

FactoryBot.define do
  factory :netbox_facet, class: 'ForemanNetbox::NetboxFacet' do
    host
    sequence(:url) { |n| "https://netbox.example.com/#{n}" }
  end
end
