# frozen_string_literal: true

FactoryBot.modify do
  factory :host do
    trait :with_netbox_facet do
      association :netbox_facet, factory: :netbox_facet, strategy: :build
    end
  end
end
