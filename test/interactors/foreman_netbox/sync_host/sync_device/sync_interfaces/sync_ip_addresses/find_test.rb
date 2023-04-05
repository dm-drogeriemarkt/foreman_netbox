# frozen_string_literal: true

require 'test_plugin_helper'

class FindDeviceIpAddressesTest < ActiveSupport::TestCase
  subject do
    ForemanNetbox::SyncHost::SyncDevice::SyncInterfaces::SyncIpAddresses::Find.call(
      device: device
    )
  end

  let(:device) { OpenStruct.new(id: 1) }

  setup do
    setup_default_netbox_settings
  end

  context 'when ip_addresses were found on Netbox' do
    it 'assigns ip_addresses to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/ipam/ip-addresses.json").with(
        query: { limit: 50, device_id: device.id }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [{ id: 1 }],
        }.to_json
      )

      assert_equal [1], subject.ip_addresses.map(&:id)
      assert_requested(stub_get)
    end
  end

  context 'when ip_addresses were not found on Netbox' do
    it 'does not assign ip_addresses to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/api/ipam/ip-addresses.json").with(
        query: { limit: 50, device_id: device.id }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: [],
        }.to_json
      )

      assert_empty subject.ip_addresses.map(&:id)
      assert_requested(stub_get)
    end
  end
end
