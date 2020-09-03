# frozen_string_literal: true

FactoryBot.modify do
  factory :host do
    trait :with_netbox_facet do
      association :netbox_facet, factory: :netbox_facet, strategy: :build
    end

    trait :with_device_netbox_facet do
      association :netbox_facet, factory: %i[netbox_facet with_device_raw_data]
    end

    trait :with_virtual_machine_netbox_facet do
      association :netbox_facet, factory: %i[netbox_facet with_virtual_machine_raw_data]
    end
  end
end
