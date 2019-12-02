# frozen_string_literal: true

require 'test_plugin_helper'

class FindManufacturerTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncDevice::SyncDeviceType::SyncManufacturer::Find.call(host: host) }

  let(:host) do
    OpenStruct.new(
      facts: {
        dmi: {
          manufacturer: 'Manufacturer'
        }
      }
    )
  end
  let(:slug) { host.facts.dig(:dmi, :manufacturer).parameterize }

  setup do
    setup_default_netbox_settings
  end

  context 'when manufacturer exists in Netbox' do
    it 'assigns manufacturer to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/dcim/manufacturers.json").with(
        query: { limit: 50, slug: slug }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [
            {
              id: 1,
              name: host.facts.dig(:dmi, :product, :name),
              slug: slug
            }
          ]
        }.to_json
      )

      assert_equal 1, subject.manufacturer.id
      assert_requested(stub_get)
    end
  end

  context 'when manufacturer does not exist in NetBox' do
    it 'does not assign manufacturer to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/dcim/manufacturers.json").with(
        query: { limit: 50, slug: slug }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: []
        }.to_json
      )

      assert_nil subject.manufacturer
      assert_requested(stub_get)
    end
  end
end
