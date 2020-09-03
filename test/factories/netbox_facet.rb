# frozen_string_literal: true

FactoryBot.define do
  factory :netbox_facet, class: 'ForemanNetbox::NetboxFacet' do
    host
    synchronized_at { Time.zone.now }
    sequence(:url) { |n| "https://netbox.example.com/#{n}" }

    trait :with_device_raw_data do
      raw_data { JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'netbox_device_raw_data.json'))) }
    end

    trait :with_virtual_machine_raw_data do
      raw_data { JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'netbox_virtual_machine_raw_data.json'))) }
    end
  end
end
